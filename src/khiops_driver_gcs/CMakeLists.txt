find_package(google_cloud_cpp_storage CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(CURL REQUIRED)
find_package(nlohmann_json REQUIRED)
if(BUILD_TESTS)
    find_package(fmt CONFIG REQUIRED)
    find_package(Boost REQUIRED)
endif()

set(SOURCES
    gcsplugin.h
    gcsplugin_internal.h
    gcsplugin.cpp
    utils.h
    utils.cpp
    oauth2_token_manager.h
    oauth2_token_manager.cpp
)
list(TRANSFORM SOURCES PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/src/")

set(LINK_LIBS google-cloud-cpp::storage spdlog::spdlog CURL::libcurl nlohmann_json::nlohmann_json)

add_driver_library(libkhiopsdriver_file_gcs "${SOURCES}" "" "${LINK_LIBS}")

if(TESTING)
    add_subdirectory(specific_tests)
endif()