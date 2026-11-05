find_package(Boost REQUIRED)
find_package(AWSSDK CONFIG COMPONENTS core s3 REQUIRED)

set(SOURCES
    s3_test.cpp
    drivertest.cpp
    "${CMAKE_SOURCE_DIR}/src/khiops_driver_common/contrib.hpp"
    "${CMAKE_SOURCE_DIR}/s3/src/s3plugin.h"
)

add_test_executable(s3_test "${SOURCES}" "${CMAKE_SOURCE_DIR}/s3/src" "${AWSSDK_LIBRARIES}")