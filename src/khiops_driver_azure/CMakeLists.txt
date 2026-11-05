find_package(azure-core-cpp CONFIG REQUIRED)
find_package(azure-identity-cpp CONFIG REQUIRED)
find_package(azure-storage-blobs-cpp CONFIG REQUIRED)
find_package(azure-storage-files-shares-cpp CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)

add_library(khiops_driver_azure SHARED
    auth.hpp
    blobpathresolve.cpp
    blobpathresolve.hpp
    connstr.cpp
    connstr.hpp
    core.cpp
    core.hpp
    driver.cpp
    filestream.cpp
    filestream.hpp
    globalstate.hpp
    sharepathresolve.cpp
    sharepathresolve.hpp
    specific_impl.cpp
    util.cpp
    util.hpp
)
target_include_directories(khiops_driver_azure PRIVATE "${CMAKE_SOURCE_DIR}/src")
target_compile_options(khiops_driver_azure PRIVATE ${COMMON_COMPILE_OPTIONS})
target_link_libraries(khiops_driver_azure PRIVATE Azure::azure-core Azure::azure-identity Azure::azure-storage-blobs Azure::azure-storage-files-shares spdlog::spdlog khiops_driver_common)
if(NOT TESTING AND NOT MSVC AND CMAKE_BUILD_TYPE STREQUAL "Release")
    target_link_options(khiops_driver_azure PRIVATE -s)
endif()

if(TESTING AND WIN32)
    set_target_properties(khiops_driver_azure PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

set_target_properties(khiops_driver_azure PROPERTIES SOVERSION "${PROJECT_VERSION_MAJOR}" VERSION "${RAW_VERSION}")
set(LIBFILENAME "libkhiopsdriver_file_azure")
set_target_properties(khiops_driver_azure PROPERTIES PREFIX "" RUNTIME_OUTPUT_NAME ${LIBFILENAME} LIBRARY_OUTPUT_NAME ${LIBFILENAME} ARCHIVE_OUTPUT_NAME ${LIBFILENAME})
# We must use these weird generator expressions to avoid the Debug and Release directories in VS: https://stackoverflow.com/q/47175912
set_target_properties(khiops_driver_azure PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin" LIBRARY_OUTPUT_DIRECTORY $<1:${CMAKE_CURRENT_BINARY_DIR}/lib> ARCHIVE_OUTPUT_DIRECTORY $<1:${CMAKE_CURRENT_BINARY_DIR}/lib>)

# These paths are needed so that Khiops finds the driver.
# 'RUNTIME DESTINATION' is used for DLLs on windows.
if(DEFINED SKBUILD)
    install(TARGETS khiops_driver_azure LIBRARY DESTINATION ${SKBUILD_DATA_DIR}/lib RUNTIME DESTINATION ${SKBUILD_SCRIPTS_DIR})
else()
    install(TARGETS khiops_driver_azure LIBRARY DESTINATION lib RUNTIME DESTINATION bin)
endif()