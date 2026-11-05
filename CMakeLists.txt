cmake_minimum_required(VERSION 3.30)

# We can only build one driver at a time because each driver has its own VCPKG toolchain and these VCPKG toolchains may be of different versions.
set(VALID_DRIVERS azure gcs s3)
set(DRIVER "" CACHE STRING "Select the driver to build among: ${VALID_DRIVERS}")
message(STATUS "Selected driver: ${DRIVER}")
if(NOT DRIVER IN_LIST VALID_DRIVERS)
  message(FATAL_ERROR "Driver '${DRIVER}' selected with DRIVER is not among valid choices '${VALID_DRIVERS}'")
endif()
option(TESTING "Build test suites and build driver libraries in testing mode" OFF)
message(STATUS "Tests: ${TESTING}")

message(STATUS "Source directory: ${CMAKE_SOURCE_DIR}")
message(STATUS "Build directory: ${CMAKE_BINARY_DIR}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Generator: ${CMAKE_GENERATOR}")
get_property(IS_GENERATOR_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_GENERATOR_MULTICONFIG)
    message(FATAL_ERROR "Multiconfiguration generators are not supported")
endif()
message(STATUS "OS: ${CMAKE_HOST_SYSTEM_NAME}")
if("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Linux" OR "${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Darwin")
    execute_process(COMMAND uname -m RESULT_VARIABLE UNAME_RESULT OUTPUT_VARIABLE ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT "${UNAME_RESULT}" STREQUAL "0")
        message(FATAL_ERROR "Unable to detect architecture (uname returned non-zero status)")
    endif()
elseif("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Windows")
    set(ARCH $ENV{PROCESSOR_ARCHITECTURE})
else()
    message(FATAL_ERROR "Unsupported OS '${CMAKE_HOST_SYSTEM_NAME}'")
endif()
message(STATUS "Architecture: ${ARCH}")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
message(STATUS "C++ version: ${CMAKE_CXX_STANDARD}")

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

# Select the vcpkg target triplet according to the host system and architecture (no cross-compilation).
# Do that before calling the 'project' command, which initializes the vcpkg toolchain.
if("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Linux")
    if("${ARCH}" STREQUAL "x86_64")
        set(VCPKG_TARGET_TRIPLET "x64-linux")
    elseif("${ARCH}" STREQUAL "aarch64")
        set(VCPKG_TARGET_TRIPLET "arm64-linux")
    else()
        message(FATAL_ERROR "Unsupported architecture '${ARCH}'")
    endif()
elseif("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Darwin")
    if("${ARCH}" STREQUAL "x86_64")
        set(VCPKG_TARGET_TRIPLET "x64-osx")
    elseif("${ARCH}" STREQUAL "arm64")
        set(VCPKG_TARGET_TRIPLET "arm64-osx")
    else()
        message(FATAL_ERROR "Unsupported architecture '${ARCH}'")
    endif()
elseif("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Windows")
    if("${ARCH}" STREQUAL "AMD64")
        if(DRIVER STREQUAL "s3")
            # Static build of vcpkg dependencies needed by the S3 driver does not work on Windows,
            # so we must build the dependencies as DLLs and package them with the driver's DLL.
            set(VCPKG_TARGET_TRIPLET "x64-windows")
        else()
            set(VCPKG_TARGET_TRIPLET "x64-windows-static")
        endif()
    else()
        message(FATAL_ERROR "Unsupported architecture '${ARCH}'")
    endif()
endif()
message(STATUS "VCPKG target triplet: ${VCPKG_TARGET_TRIPLET}")

project("khiops-drivers" LANGUAGES CXX VERSION "${NOSUFFIX_VERSION}")

# If compiling with MSVC, select the correct MSVC runtime based on the VCPKG target triplet and the build type.
if(MSVC)
    if(VCPKG_TARGET_TRIPLET MATCHES "-static$")
        if(CMAKE_BUILD_TYPE STREQUAL "Release")
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded")
        else()
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDebug")
        endif()
    else()
        if(CMAKE_BUILD_TYPE STREQUAL "Release")
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
        else()
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDebugDLL")
        endif()
    endif()
    message(STATUS "MSVC runtime: ${CMAKE_MSVC_RUNTIME_LIBRARY}")
endif()

if(TESTING)
    include(FetchContent)
    FetchContent_Declare(googletest GIT_REPOSITORY "https://github.com/google/googletest.git" GIT_TAG "v1.14.0" GIT_PROGRESS ON)
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)

    include(GoogleTest)
    enable_testing()

    # On Linux and non-release builds, enable sanitizers.
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND NOT CMAKE_BUILD_TYPE STREQUAL "Release")
        add_compile_options(-fsanitize=undefined -fsanitize=address -fno-sanitize-recover=all)
        add_link_options(-fsanitize=undefined -fsanitize=address -fno-sanitize-recover=all)
    endif()
endif()

include_directories("${CMAKE_SOURCE_DIR}/src")

if(MSVC)
    add_compile_options(/wd4582 /wd4583 /wd4625 /wd4626 /wd4710 /wd4711 /wd4820 /wd4868 /wd4365 /wd5045 /bigobj /utf-8)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-Wall -Wextra -pedantic)
endif()

if(NOT TESTING AND NOT MSVC AND CMAKE_BUILD_TYPE STREQUAL "Release")
    add_link_options(-s)
endif()

# Hide symbols in the shared libraries to only expose the public functions to be used by the end-user.
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)

# Avoid generating shared libraries with version numbers in the filenames.
set(CMAKE_PLATFORM_NO_VERSIONED_SONAME ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/outputs")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/outputs")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/outputs")

function(configure_driver_package NAME SUMMARY DESC)
    if(TESTING OR NOT CMAKE_BUILD_TYPE STREQUAL "Release")
        message(STATUS "Building driver in testing mode or in non-release configuration, skipping package configuration")
        return()
    endif()

    # === GENERIC INFORMATION ===
    set(CPACK_PACKAGE_NAME "${NAME}")
    set(CPACK_PACKAGE_VERSION "${RAW_VERSION}")
    set(CPACK_PACKAGE_VENDOR "Orange")
    set(CPACK_PACKAGE_CONTACT "Khiops Team <khiops.team@orange.com>")
    set(CPACK_PACKAGE_HOMEPAGE_URL "https://khiops.org")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${SUMMARY}")
    set(CPACK_PACKAGE_DESCRIPTION "${DESC}")
    set(CPACK_VERBATIM_VARIABLES YES)
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "${CPACK_PACKAGE_NAME}") ################################ À SUPPRIMER ???
    set(CPACK_PACKAGE_DIRECTORY "${CMAKE_BINARY_DIR}/packages")

    # === DEB ===
    set(CPACK_DEBIAN_PACKAGE_RELEASE "1")
    set(CPACK_DEBIAN_PACKAGE_VERSION "${TILDESUFFIX_VERSION}")
    set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
    set(CPACK_DEBIAN_PACKAGE_SECTION "math")
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON) # Needed to add the stdlib as a dependency of the package.
    set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "khiops")
    set(CPACK_DEBIAN_PACKAGE_CONTROL_STRICT_PERMISSION TRUE)

    # === RPM ===
    set(CPACK_RPM_PACKAGE_RELEASE "1")
    set(CPACK_RPM_PACKAGE_VERSION "${TILDESUFFIX_VERSION}")
    set(CPACK_RPM_FILE_NAME RPM-DEFAULT)
    set(CPACK_RPM_PACKAGE_GROUP "Applications/Engineering")
    set(CPACK_RPM_PACKAGE_LICENSE "BSD-3-Clause")

    include(CPack)
endfunction()

add_subdirectory(src)
if(TESTING)
    add_subdirectory(test)
endif()