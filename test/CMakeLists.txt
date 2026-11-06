include(FetchContent)
FetchContent_Declare(googletest GIT_REPOSITORY "https://github.com/google/googletest.git" GIT_TAG "v1.14.0")

set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

find_package(Boost COMPONENTS process REQUIRED)

add_executable(basic_test
    test_basic.cpp
    test_io.cpp
    test_end_to_end.cpp
    fixture_storage.hpp
    returnval.hpp
    utils.hpp
    urls.hpp
    errorstrings.hpp
    errorstrings.cpp
    function_specific/driver_remove.cpp
    function_specific/driver_mkdir.cpp
    function_specific/driver_rmdir.cpp
    function_specific/driver_fclose.cpp
    "${CMAKE_SOURCE_DIR}/src/khiops_driver_common/driver.h"
)

target_include_directories(basic_test PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_SOURCE_DIR}/src)

target_compile_options(basic_test
    PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/wd4582;/wd4583;/wd4625;/wd4626;/wd4710;/wd4711;/wd4820;/wd4868;/wd4365;/wd5045>
    PRIVATE $<$<CXX_COMPILER_ID:AppleClang,Clang,GNU>:-Wall;-Wextra;-pedantic>
)

# MSVC requires /bigobj to build in debug config.
target_compile_options(basic_test PRIVATE $<$<AND:$<CONFIG:Debug>,$<CXX_COMPILER_ID:MSVC>>:/bigobj>)

target_link_libraries(basic_test PRIVATE
    driver
    GTest::gtest GTest::gmock GTest::gmock_main
    ${Boost_LIBRARIES}
    fmt::fmt
)
if(WIN32)
    target_link_libraries(basic_test PRIVATE bcrypt)
endif()

if(DEFINED LSAN_SUPPRESSION_FILE)
    gtest_discover_tests(basic_test PROPERTIES ENVIRONMENT "LSAN_OPTIONS=suppressions=${LSAN_SUPPRESSION_FILE}")
else()
    gtest_discover_tests(basic_test)
endif()
