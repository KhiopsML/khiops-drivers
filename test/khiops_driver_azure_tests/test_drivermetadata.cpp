#include "khiops_driver_common/driver.h"
#include "khiops_driver_common/version.hpp"
#include <gtest/gtest.h>

TEST(DriverMetadataTest, GetDriverName) {
  ASSERT_STREQ(driver_getDriverName(), "Azure driver");
}

TEST(DriverMetadataTest, GetVersion) {
  ASSERT_STREQ(driver_getVersion(), DRIVER_VERSION);
}

TEST(DriverMetadataTest, GetScheme) {
  ASSERT_STREQ(driver_getScheme(), "https");
}