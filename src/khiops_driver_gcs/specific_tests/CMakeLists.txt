find_package(Boost CONFIG REQUIRED)

set(SOURCES
    mocking_test.cpp
    nonmocking_test.cpp
    oauth2_token_manager_test.cpp
    test_drivermetadata.cpp
    "${CMAKE_SOURCE_DIR}/gcs/src/oauth2_token_manager.cpp"
    "${CMAKE_SOURCE_DIR}/gcs/src/gcsplugin.h"
)

add_test_executable(gcs_test "${SOURCES}" "${CMAKE_SOURCE_DIR}/gcs/src" "google-cloud-cpp::storage")