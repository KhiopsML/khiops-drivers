find_package(Boost CONFIG REQUIRED COMPONENTS process uuid)

add_library(khiops_driver_shared_tests OBJECT
    errorstrings.cpp
    errorstrings.hpp
    fixture_storage.hpp
    returnval.hpp
    test_basic.cpp
    test_end_to_end.cpp
    test_function_driver_fclose.cpp
    test_function_driver_mkdir.cpp
    test_function_driver_remove.cpp
    test_function_driver_rmdir.cpp
    test_io.cpp
    urls.hpp
    utils.hpp
)
target_compile_options(khiops_driver_shared_tests PRIVATE ${COMMON_COMPILE_OPTIONS})
target_include_directories(khiops_driver_shared_tests PRIVATE "${CMAKE_SOURCE_DIR}/src")
target_link_libraries(khiops_driver_shared_tests PRIVATE GTest::gtest GTest::gmock Boost::process Boost::uuid)

add_executable(khiops_driver_azure_shared_tests)
target_compile_options(khiops_driver_azure_shared_tests PRIVATE ${COMMON_COMPILE_OPTIONS})
target_link_libraries(khiops_driver_azure_shared_tests PRIVATE GTest::gmock_main khiops_driver_shared_tests khiops_driver_azure)
gtest_discover_tests(khiops_driver_azure_shared_tests PROPERTIES ENVIRONMENT "LSAN_OPTIONS=suppressions=${CMAKE_SOURCE_DIR}/khiops_driver_azure_lsan_suppr.txt")

# add_executable(khiops_driver_gcs_shared_tests)
# target_compile_options(khiops_driver_gcs_shared_tests PRIVATE ${COMMON_COMPILE_OPTIONS})
# target_link_libraries(khiops_driver_gcs_shared_tests PRIVATE GTest::gmock_main khiops_driver_shared_tests khiops_driver_gcs)
# gtest_discover_tests(khiops_driver_gcs_shared_tests)
# 
# add_executable(khiops_driver_s3_shared_tests)
# target_compile_options(khiops_driver_s3_shared_tests PRIVATE ${COMMON_COMPILE_OPTIONS})
# target_link_libraries(khiops_driver_s3_shared_tests PRIVATE GTest::gmock_main khiops_driver_shared_tests khiops_driver_s3)
# gtest_discover_tests(khiops_driver_s3_shared_tests PROPERTIES ENVIRONMENT "LSAN_OPTIONS=suppressions=${CMAKE_SOURCE_DIR}/khiops_driver_s3_lsan_suppr.txt")