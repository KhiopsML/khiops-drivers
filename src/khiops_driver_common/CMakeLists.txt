find_package(spdlog CONFIG REQUIRED)
add_library(khiops_driver_common OBJECT
    checks.cpp
    checks.hpp
    contrib.hpp
    driver.h
    filestream_management.hpp
    globalstate.hpp
    logging.cpp
    logging.hpp
    returnval.hpp
    stringify.hpp
    userfunc_checks.cpp
    userfunc_checks.hpp
    util.cpp
    util.hpp
    version.hpp
)
target_compile_options(khiops_driver_common PRIVATE ${COMMON_COMPILE_OPTIONS})
target_include_directories(khiops_driver_common PRIVATE "${CMAKE_SOURCE_DIR}/src")
target_link_libraries(khiops_driver_common PRIVATE spdlog::spdlog)
set_target_properties(khiops_driver_common PROPERTIES POSITION_INDEPENDENT_CODE ON)