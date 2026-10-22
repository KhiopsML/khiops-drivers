#include <string>
#include <gtest/gtest.h>
#include "../fixture_storage.hpp"
#include "khiops_driver_common/driver.h"
#include "../returnval.hpp"
#include "../errorstrings.hpp"
#include "../utils.hpp"

using namespace std;

class DriverRmdirTest : public StorageTest {};

TEST_F(DriverRmdirTest, SimplestCaseOK) {
    string created_dir; this->CreateRandomDir(&created_dir);
    // Make sure the remote directory exists.
    ASSERT_EQ(driver_dirExists(created_dir.c_str()), kTrue) << "Remote directory not found after its creation.";
    // Remove the remote directory.
    ASSERT_EQ(driver_rmdir(created_dir.c_str()), kOtherSuccess) << "Failed to remove remote directory.";
    // Make sure the remote directory does not exist anymore.
    ASSERT_EQ(driver_dirExists(created_dir.c_str()), kFalse) << "Remote directory still found after its removal.";
}

TEST_F(DriverRmdirTest, RecursiveRemovalOK) {
    string dir_root; this->CreateRandomDir(&dir_root);
    this->CreateDirAt(dir_root + "a/");
    this->CreateDirAt(dir_root + "a/aa/");
    this->CreateDirAt(dir_root + "b/");
    this->CreateDirAt(dir_root + "b/ba/");
    this->CreateEmptyFileAt(dir_root + "b/ba/baa");
    this->CreateDirAt(dir_root + "b/ba/bab/");
    this->CreateDirAt(dir_root + "b/bb/");
    ASSERT_EQ(driver_rmdir(dir_root.c_str()), kOtherSuccess);
    ASSERT_EQ(driver_dirExists((dir_root + "a/").c_str()), kFalse);
    ASSERT_EQ(driver_dirExists((dir_root + "a/aa/").c_str()), kFalse);
    ASSERT_EQ(driver_dirExists((dir_root + "b/").c_str()), kFalse);
    ASSERT_EQ(driver_dirExists((dir_root + "b/ba/").c_str()), kFalse);
    ASSERT_EQ(driver_fileExists((dir_root + "b/ba/baa").c_str()), kFalse);
    ASSERT_EQ(driver_dirExists((dir_root + "b/ba/bab/").c_str()), kFalse);
    ASSERT_EQ(driver_dirExists((dir_root + "b/bb/").c_str()), kFalse);
}

// Removing a directory without a trailing slash must preserve similarly named siblings.
TEST_F(DriverRmdirTest, WithoutTrailingSlashKeepsSiblingPrefix) {
    string parent_dir; this->CreateRandomDir(&parent_dir);
    const string target_dir = parent_dir + "reports/";
    const string slashless_dir = parent_dir + "reports";
    const string sibling_dir = parent_dir + "reports-old/";
    const string sibling_file = parent_dir + "reports.txt";
    const string nested_dir = target_dir + "nested/";
    const string nested_file = nested_dir + "data.txt";
    this->CreateDirAt(target_dir);
    this->CreateDirAt(nested_dir);
    this->CreateEmptyFileAt(nested_file);
    this->CreateDirAt(sibling_dir);
    this->CreateEmptyFileAt(sibling_file);

    ASSERT_EQ(driver_dirExists(target_dir.c_str()), kTrue);
    ASSERT_EQ(driver_dirExists(slashless_dir.c_str()), kTrue);
    ASSERT_EQ(driver_rmdir(slashless_dir.c_str()), kOtherSuccess);
    ASSERT_EQ(driver_dirExists(target_dir.c_str()), kFalse);
    ASSERT_EQ(driver_dirExists(slashless_dir.c_str()), kFalse);
    ASSERT_EQ(driver_dirExists(nested_dir.c_str()), kFalse);
    ASSERT_EQ(driver_fileExists(nested_file.c_str()), kFalse);
    ASSERT_EQ(driver_dirExists(sibling_dir.c_str()), kTrue);
    ASSERT_EQ(driver_fileExists(sibling_file.c_str()), kTrue);
}