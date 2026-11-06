cmake_minimum_required(VERSION 3.21)

# Ensure to pick up the default triplet from the environment if any. This helps driving the vcpkg triplet in the same
# way either when starting vcpkg directly, or when letting CMake start vcpkg at configure/generate time.
# Note: this logic must happen before 'project' command.
if(DEFINED ENV{VCPKG_DEFAULT_TRIPLET} AND NOT DEFINED VCPKG_TARGET_TRIPLET)
  set(VCPKG_TARGET_TRIPLET "$ENV{VCPKG_DEFAULT_TRIPLET}" CACHE STRING "The vcpkg triplet")
endif()

# Read raw version from file.
file(READ "${CMAKE_SOURCE_DIR}/src/khiops_driver_common/version.hpp" VERSION_FILE)
string(REGEX MATCH "#define DRIVER_VERSION \"([^\"]+)\"" _ "${VERSION_FILE}")
set(RAW_VERSION "${CMAKE_MATCH_1}")
message(STATUS "Raw version: ${RAW_VERSION}")

# Remove suffix from raw version.
string(REGEX REPLACE "-.*" "" NOSUFFIX_VERSION "${RAW_VERSION}")
message(STATUS "No-suffix version: ${NOSUFFIX_VERSION}")

# Some package formats use a tilde to separate the version base from the suffix because they
# already use the hyphen to separate the content version from the package release version.
# Examples of this are deb and rpm formats.
string(REPLACE "-" "~" TILDESUFFIX_VERSION "${RAW_VERSION}")
message(STATUS "Tilde-suffix version: ${TILDESUFFIX_VERSION}")

project("khiops-driver" LANGUAGES CXX VERSION "${NOSUFFIX_VERSION}")

message(STATUS "Source directory: ${CMAKE_SOURCE_DIR}")
message(STATUS "Build directory: ${CMAKE_BINARY_DIR}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

# User inputs
set(DRIVER "" CACHE STRING "Driver to configure: azure, gcs, or s3")
message(STATUS "Driver: ${DRIVER}")
option(TESTING "Build test suites and build driver library in testing mode" OFF)
message(STATUS "Tests: ${TESTING}")

# Set path to find modules like CodeCoverage.
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules/)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
message(STATUS "C++ version: ${CMAKE_CXX_STANDARD}")

if(MSVC)
    # Set CMake policy for MSVC runtime selection.
    if(POLICY CMP0091)
        cmake_policy(SET CMP0091 NEW)
    endif()

    # Set MSVC runtime from VCPKG triplet.
    if(DEFINED VCPKG_TARGET_TRIPLET)
        string(TOLOWER "${VCPKG_TARGET_TRIPLET}" VCPKG_TARGET_TRIPLET_LOWERCASE)
        if(VCPKG_TARGET_TRIPLET_LOWERCASE MATCHES "-static$")
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
        else()
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
        endif()
        message(STATUS "MSVC runtime: ${CMAKE_MSVC_RUNTIME_LIBRARY} (derived from VCPKG_TARGET_TRIPLET: ${VCPKG_TARGET_TRIPLET})")
    else()
        message(WARNING "VCPKG_TARGET_TRIPLET undefined; runtime MSVC not forced. To avoid LNK2038 conflicts, pass -DVCPKG_TARGET_TRIPLET=...")
    endif()
endif()

if(TESTING)
    # Exclude googletest from the installation and packages.
    set(INSTALL_GTEST OFF)
    set(INSTALL_GMOCK OFF)

    include(GoogleTest)
    enable_testing()

    if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND NOT CMAKE_BUILD_TYPE STREQUAL "Release")
        # Enable sanitizers.
        add_compile_options(-fsanitize=undefined -fsanitize=address -fno-sanitize-recover=all)
        add_link_options(-fsanitize=undefined -fsanitize=address -fno-sanitize-recover=all)

        # Enable code coverage.
        include(CodeCoverage)
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_COVERAGE} ${CMAKE_CXX_FLAGS_DEBUG}")
        setup_target_for_coverage(${PROJECT_NAME}_coverage basic_test coverage)
        setup_target_for_coverage_cobertura(${PROJECT_NAME}_cobertura basic_test coverage --gtest_output=xml:coverage.junit.xml)
    endif()
    
    add_subdirectory("test")
else()
    # Hide symbols in the shared libraries to only expose the public functions to be used by the end-user.
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)
endif()

# Avoid generating shared libraries with version numbers in the filenames.
set(CMAKE_PLATFORM_NO_VERSIONED_SONAME ON)

# Import 'add_driver' function.
include(driver)

if(DRIVER STREQUAL "azure")
    set(LSAN_SUPPRESSION_FILE "azure/lsan_suppressions.txt")
    add_subdirectory("azure")
elseif(DRIVER STREQUAL "gcs")
    add_subdirectory("gcs")
elseif(DRIVER STREQUAL "s3")
    set(LSAN_SUPPRESSION_FILE "s3/lsan_suppressions.txt")
    add_subdirectory("s3")
else()
    message(FATAL_ERROR "DRIVER is set to '${DRIVER}' but must be one of 'azure', 'gcs', or 's3'")
endif()

return()


# Helper: per-driver extra CMake args (Windows triplet, vcpkg toolchain...)
macro(_driver_extra_cmake_args _driver _out_var)
  set(${_out_var} "")
  if(WIN32 AND CMAKE_SYSTEM_PROCESSOR MATCHES "AMD64|x86_64")
    if("${_driver}" STREQUAL "azure" OR "${_driver}" STREQUAL "gcs")
      list(APPEND ${_out_var} "-DVCPKG_TARGET_TRIPLET=x64-windows-static")
    endif()
  endif()
  list(APPEND ${_out_var}
    "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_CURRENT_SOURCE_DIR}/${_driver}/vcpkg/scripts/buildsystems/vcpkg.cmake"
    "-DVCPKG_MANIFEST_DIR=${CMAKE_CURRENT_SOURCE_DIR}/${_driver}"
  )
endmacro()


# pip packaging via scikit-build-core (SKBUILD is defined)
if(DEFINED SKBUILD)
  include(ExternalProject)

  # Common CMake args forwarded to every sub-build.
  set(_common_args
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -DSKBUILD=1
    "-DSKBUILD_DATA_DIR=${SKBUILD_DATA_DIR}"
    "-DSKBUILD_SCRIPTS_DIR=${SKBUILD_SCRIPTS_DIR}"
  )

  foreach(_driver azure gcs s3)
    _driver_extra_cmake_args(${_driver} _extra)
    ExternalProject_Add(driver_${_driver}
      SOURCE_DIR        "${CMAKE_CURRENT_SOURCE_DIR}/${_driver}"
      BINARY_DIR        "${CMAKE_CURRENT_BINARY_DIR}/${_driver}"
      INSTALL_DIR       "${CMAKE_CURRENT_BINARY_DIR}/${_driver}/install"
      CMAKE_ARGS        ${_common_args} ${_extra}
      BUILD_ALWAYS      OFF
      INSTALL_COMMAND   ${CMAKE_COMMAND} --install <BINARY_DIR>
    )
  endforeach()

# ---------------------------------------------------------------------------
# Mode 2 – DEB / RPM packaging (KHIOPS_PACKAGE_ALL=ON)
# ---------------------------------------------------------------------------
elseif(KHIOPS_PACKAGE_ALL)
  include(ExternalProject)

  set(_staging "${CMAKE_BINARY_DIR}/staging")

  set(_common_args
    -DCMAKE_BUILD_TYPE=Release
    "-DCMAKE_INSTALL_PREFIX=${_staging}"
  )

  foreach(_driver azure gcs s3)
    _driver_extra_cmake_args(${_driver} _extra)
    ExternalProject_Add(driver_${_driver}
      SOURCE_DIR        "${CMAKE_CURRENT_SOURCE_DIR}/${_driver}"
      BINARY_DIR        "${CMAKE_CURRENT_BINARY_DIR}/${_driver}"
      CMAKE_ARGS        ${_common_args} ${_extra}
      BUILD_ALWAYS      OFF
      INSTALL_COMMAND   ${CMAKE_COMMAND} --install <BINARY_DIR>
    )
  endforeach()

  # Aggregate all three shared libraries into the CPack install tree.
  # The staging directory is populated by cmake --build via the ExternalProjects.
  if(WIN32)
    # Install all DLLs: the three driver DLLs, plus the S3 runtime dependencies
    # (S3 uses the dynamic x64-windows triplet, unlike Azure/GCS which are fully static).
    install(DIRECTORY "${_staging}/bin/"
            DESTINATION bin
            FILES_MATCHING PATTERN "*.dll")
  elseif(APPLE)
    install(DIRECTORY "${_staging}/lib/"
            DESTINATION lib
            FILES_MATCHING PATTERN "libkhiopsdriver_file_*.dylib")
  else()
    install(DIRECTORY "${_staging}/lib/"
            DESTINATION lib
            FILES_MATCHING PATTERN "libkhiopsdriver_file_*")
  endif()

  # ---- CPack unified package ----
  set(CPACK_PACKAGE_NAME "khiops-drivers")
  set(CPACK_PACKAGE_VERSION "${DRIVERS_VERSION}")
  set(CPACK_PACKAGE_VENDOR "Orange")
  set(CPACK_PACKAGE_CONTACT "Khiops Team <khiops.team@orange.com>")
  set(CPACK_PACKAGE_HOMEPAGE_URL "https://khiops.org")
  set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
  set(CPACK_SOURCE_IGNORE_FILES ".git")
  set(CPACK_PACKAGE_DESCRIPTION
      "These drivers allow Khiops to access Azure, Google Cloud Storage and Amazon S3.")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY
      "Azure, GCS and S3 drivers for the Khiops tool")
  set(CPACK_VERBATIM_VARIABLES YES)
  set(CPACK_PACKAGE_INSTALL_DIRECTORY ${CPACK_PACKAGE_NAME})
  set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_BINARY_DIR}/packages")

  # ---- DEB ----
  set(CPACK_DEBIAN_PACKAGE_RELEASE "1")
  set(CPACK_DEBIAN_PACKAGE_VERSION "${DRIVERS_VERSION_TILDE_SUFFIX}")
  set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
  set(CPACK_DEBIAN_PACKAGE_SECTION "math")
  set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
  set(CPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS ON)
  # dpkg-shlibdeps scans the staging lib dir where the .so files live after build.
  set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS "${_staging}/lib/")
  set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "khiops")
  set(CPACK_DEBIAN_PACKAGE_CONTROL_STRICT_PERMISSION TRUE)

  # ---- RPM ----
  set(CPACK_RPM_PACKAGE_RELEASE "1")
  set(CPACK_RPM_PACKAGE_VERSION "${DRIVERS_VERSION_TILDE_SUFFIX}")
  set(CPACK_RPM_PACKAGE_LICENSE "BSD-3-Clause")
  set(CPACK_RPM_PACKAGE_GROUP "Applications/Engineering")
  set(CPACK_RPM_PACKAGE_VENDOR "Orange")
  set(CPACK_RPM_PACKAGE_AUTOREQ ON)
  set(CPACK_RPM_FILE_NAME RPM-DEFAULT)

  include(CPack)

# ---------------------------------------------------------------------------
# Mode 3 – developer build (single driver selected via -DKHIOPS_DRIVER=...)
# ---------------------------------------------------------------------------
else()
  

  if(KHIOPS_DRIVER STREQUAL "azure")
    add_subdirectory(azure)
  elseif(KHIOPS_DRIVER STREQUAL "gcs")
    add_subdirectory(gcs)
  elseif(KHIOPS_DRIVER STREQUAL "s3")
    add_subdirectory(s3)
  else()
    message(FATAL_ERROR "Unsupported KHIOPS_DRIVER='${KHIOPS_DRIVER}'. Expected azure, gcs, or s3")
  endif()
endif()