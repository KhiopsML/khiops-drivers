cmake_minimum_required(VERSION 3.21)

# Read the shared version before the project() call so it is available everywhere.
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/src/khiops_driver_common/version.hpp" _ver_file)
string(REGEX MATCH "#define DRIVER_VERSION \"([^\"]+)\"" _ "${_ver_file}")
set(DRIVERS_VERSION "${CMAKE_MATCH_1}")
string(REGEX REPLACE "-.*" "" DRIVERS_VERSION_SHORT "${DRIVERS_VERSION}")

project(khiops-drivers
  LANGUAGES CXX
  VERSION "${DRIVERS_VERSION_SHORT}")

# ---------------------------------------------------------------------------
# Helper: per-driver extra CMake args (Windows triplet, vcpkg toolchain…)
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Mode 1 – pip packaging via scikit-build-core (SKBUILD is defined)
#   Build all three drivers as independent ExternalProject sub-builds, each
#   using its own vcpkg checkout, then collect and install the shared libraries.
# ---------------------------------------------------------------------------
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
#   Build all three drivers into a common staging directory, then let CPack
#   bundle the three shared libraries into a single package.
#
#   Typical workflow:
#     cmake --preset all-ninja-rel
#     cmake --build --preset all-ninja-rel
#     cpack --preset all-ninja-rel -G DEB   (or -G RPM)
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
    install(DIRECTORY "${_staging}/bin/"
            DESTINATION bin
            FILES_MATCHING PATTERN "libkhiopsdriver_file_*.dll")
    install(DIRECTORY "${_staging}/lib/"
            DESTINATION lib
            FILES_MATCHING PATTERN "libkhiopsdriver_file_*.lib")
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
  set(CPACK_DEBIAN_PACKAGE_RELEASE 1)
  set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
  set(CPACK_DEBIAN_PACKAGE_SECTION "math")
  set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
  set(CPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS ON)
  # dpkg-shlibdeps scans the staging lib dir where the .so files live after build.
  set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS "${_staging}/lib/")
  set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "khiops")
  set(CPACK_DEBIAN_PACKAGE_CONTROL_STRICT_PERMISSION TRUE)

  # ---- RPM ----
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
  set(KHIOPS_DRIVER
      ""
      CACHE STRING "Driver to configure: azure, gcs, or s3")
  set_property(CACHE KHIOPS_DRIVER PROPERTY STRINGS azure gcs s3)

  if(KHIOPS_DRIVER STREQUAL "")
    message(FATAL_ERROR "KHIOPS_DRIVER must be set to one of: azure, gcs, s3")
  endif()

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