#include <gtest/gtest.h>
#include "khiops_driver_gcs/gcsplugin.h"
#include "khiops_driver_common/version.hpp"

TEST(DriverMetadataTest, GetDriverName) {
  ASSERT_STREQ(driver_getDriverName(), "GCS driver");
}

TEST(DriverMetadataTest, GetVersion) {
  ASSERT_STREQ(driver_getVersion(), DRIVER_VERSION);
}

TEST(DriverMetadataTest, GetScheme) { ASSERT_STREQ(driver_getScheme(), "gs"); }