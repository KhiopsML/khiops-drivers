find_package(ZLIB REQUIRED)
find_package(AWSSDK CONFIG COMPONENTS s3 REQUIRED)
find_package(spdlog CONFIG REQUIRED)
add_library(khiops_driver_s3_objlib OBJECT s3plugin_internal.h s3plugin.cpp s3plugin.h)
target_link_libraries(khiops_driver_s3_objlib PUBLIC ${AWSSDK_LIBRARIES} spdlog::spdlog khiops_driver_common ini_parser)
set_target_properties(khiops_driver_s3_objlib PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(khiops_driver_s3 SHARED)
target_link_libraries(khiops_driver_s3 PRIVATE khiops_driver_s3_objlib)
set_target_properties(khiops_driver_s3 PROPERTIES SOVERSION "${PROJECT_VERSION_MAJOR}" VERSION "${RAW_VERSION}")
if(TESTING)
    set(LIBFILENAME "libkhiopsdriver_file_s3_testing")
else()
    set(LIBFILENAME "libkhiopsdriver_file_s3")
endif()
set_target_properties(khiops_driver_s3 PROPERTIES PREFIX "" RUNTIME_OUTPUT_NAME ${LIBFILENAME} LIBRARY_OUTPUT_NAME ${LIBFILENAME} ARCHIVE_OUTPUT_NAME ${LIBFILENAME})
# These paths are needed so that Khiops finds the driver.
# 'RUNTIME DESTINATION' is used for DLLs on windows.
if(DEFINED SKBUILD)
    install(TARGETS khiops_driver_s3 LIBRARY DESTINATION ${SKBUILD_DATA_DIR}/lib RUNTIME DESTINATION ${SKBUILD_SCRIPTS_DIR})
else()
    install(TARGETS khiops_driver_s3 LIBRARY DESTINATION lib RUNTIME DESTINATION bin)
endif()

# On Windows, static build of vcpkg dependencies does not work for the S3 driver,
# so we must provide the depdendencies' DLLs in the driver's package.
if(WIN32)
    if(DEFINED SKBUILD)
        install(CODE "
            file(GLOB dlls LIST_DIRECTORIES false \"${CMAKE_BINARY_DIR}/outputs/*.dll\")
            if(NOT dlls)
                message(FATAL_ERROR \"Failed to find the DLLs of the dependencies in '${CMAKE_BINARY_DIR}/outputs/'.\")
            endif()
            list(REMOVE_ITEM dlls \"${CMAKE_BINARY_DIR}/outputs/libkhiopsdriver_file_s3.dll\")
            file(INSTALL DESTINATION ${SKBUILD_SCRIPTS_DIR} TYPE FILE FILES \${dlls})
        ")
    else()
        install(CODE "
            file(GLOB dlls LIST_DIRECTORIES false \"${CMAKE_BINARY_DIR}/outputs/*.dll\")
            if(NOT dlls)
                message(FATAL_ERROR \"Failed to find the DLLs of the dependencies in '${CMAKE_BINARY_DIR}/outputs/'.\")
            endif()
            list(REMOVE_ITEM dlls \"${CMAKE_BINARY_DIR}/outputs/libkhiopsdriver_file_s3.dll\")
            file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/bin\" TYPE FILE FILES \${dlls})
        ")
    endif()
endif()

add_subdirectory(contrib)

configure_driver_package(
    khiops-driver-s3
    "Khiops driver to access files on AWS S3 storage"
    "The S3 driver plugin extends Khiops to enable processing of data files located on AWS S3 compatible storage."
)