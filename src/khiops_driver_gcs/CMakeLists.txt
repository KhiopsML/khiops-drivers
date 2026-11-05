find_package(google_cloud_cpp_storage CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(CURL REQUIRED)
find_package(nlohmann_json REQUIRED)
add_library(khiops_driver_gcs_objlib OBJECT
    gcsplugin_internal.h
    gcsplugin.cpp
    gcsplugin.h
    oauth2_token_manager.cpp
    oauth2_token_manager.h
    utils.cpp
    utils.h
)
target_link_libraries(khiops_driver_gcs_objlib PUBLIC google-cloud-cpp::storage spdlog::spdlog CURL::libcurl nlohmann_json::nlohmann_json khiops_driver_common)
set_target_properties(khiops_driver_gcs_objlib PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(khiops_driver_gcs SHARED)
target_link_libraries(khiops_driver_gcs PRIVATE khiops_driver_gcs_objlib)
set_target_properties(khiops_driver_gcs PROPERTIES SOVERSION "${PROJECT_VERSION_MAJOR}" VERSION "${RAW_VERSION}")
if(TESTING)
    set(LIBFILENAME "libkhiopsdriver_file_gcs_testing")
else()
    set(LIBFILENAME "libkhiopsdriver_file_gcs")
endif()
set_target_properties(khiops_driver_gcs PROPERTIES PREFIX "" RUNTIME_OUTPUT_NAME ${LIBFILENAME} LIBRARY_OUTPUT_NAME ${LIBFILENAME} ARCHIVE_OUTPUT_NAME ${LIBFILENAME})
# These paths are needed so that Khiops finds the driver.
# 'RUNTIME DESTINATION' is used for DLLs on windows.
if(DEFINED SKBUILD)
    install(TARGETS khiops_driver_gcs LIBRARY DESTINATION ${SKBUILD_DATA_DIR}/lib RUNTIME DESTINATION ${SKBUILD_SCRIPTS_DIR})
else()
    install(TARGETS khiops_driver_gcs LIBRARY DESTINATION lib RUNTIME DESTINATION bin)
endif()

configure_driver_package(
    khiops-driver-gcs
    "Khiops driver to access files on Google Cloud Storage"
    "The GCS driver plugin extends Khiops to enable processing of data files located on Google Cloud Storage."
)