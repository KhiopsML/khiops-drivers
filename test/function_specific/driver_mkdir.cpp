#include <string>
#include <vector>
#include <gtest/gtest.h>
#include "../fixture_storage.hpp"
#include "khiops_driver_common/driver.h"
#include "../returnval.hpp"
#include "../errorstrings.hpp"
#include "../utils.hpp"

using namespace std;

class DriverMkdirTest : public StorageTest {};

TEST_F(DriverMkdirTest, SimplestCaseOK) {
    string created_dir = this->url.NewRandomDir();
    // Make sure the remote directory does not already exist.
    ASSERT_EQ(driver_dirExists(created_dir.c_str()), kFalse) << "Randomly named remote directory already exists: random name collision.";
    this->PlanDirCleanup(created_dir);
    // Create the remote directory.
    ASSERT_EQ(driver_mkdir(created_dir.c_str()), kOtherSuccess) << "Failed to create remote directory.";
    // Make sure the remote directory now exists.
    ASSERT_EQ(driver_dirExists(created_dir.c_str()), kTrue) << "Remote directory not found after its creation.";
}

TEST_F(DriverMkdirTest, WithoutTrailingSlashOK) {
    const string created_dir = this->url.NewRandomDir();
    const string slashless_dir = created_dir.substr(0, created_dir.size() - 1);
    ASSERT_EQ(driver_dirExists(slashless_dir.c_str()), kFalse);
    this->PlanDirCleanup(created_dir);
    ASSERT_EQ(driver_mkdir(slashless_dir.c_str()), kOtherSuccess);
    ASSERT_EQ(driver_dirExists(created_dir.c_str()), kTrue);
    ASSERT_EQ(driver_dirExists(slashless_dir.c_str()), kTrue);
    ASSERT_EQ(driver_rmdir(created_dir.c_str()), kOtherSuccess);
    ASSERT_EQ(driver_dirExists(created_dir.c_str()), kFalse);
    ASSERT_EQ(driver_dirExists(slashless_dir.c_str()), kFalse);
}