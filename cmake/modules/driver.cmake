function(add_driver LIBFILENAME SOURCES EXTRA_INCLUDE_DIRS LINK_LIBS)
    set(COMMON_SOURCES
        checks.hpp
        contrib.hpp
        driver.h
        filestream_management.hpp
        globalstate.hpp
        logging.hpp
        logging.cpp
        returnval.hpp
        stringify.hpp
        userfunc_checks.hpp
        userfunc_checks.cpp
        util.hpp
        util.cpp
    )
    list(TRANSFORM COMMON_SOURCES PREPEND src/khiops_driver_common/)

    add_library(driver SHARED ${COMMON_SOURCES} ${SOURCES})

    target_include_directories(driver PRIVATE "${CMAKE_SOURCE_DIR}/src" ${CMAKE_CURRENT_SOURCE_DIR}/src ${EXTRA_INCLUDE_DIRS})
    target_compile_options(driver
        PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/wd4582;/wd4583;/wd4625;/wd4626;/wd4710;/wd4711;/wd4820;/wd4868;/wd4365;/wd5045>
        PRIVATE $<$<CXX_COMPILER_ID:AppleClang,Clang,GNU>:-Wall;-Wextra;-pedantic>
    )
    target_link_libraries(driver PRIVATE ${LINK_LIBS})
    if(NOT TESTING AND NOT MSVC)
        target_link_options(driver PRIVATE $<$<CONFIG:RELEASE>:-s>)
    endif()

    set_target_properties(driver PROPERTIES SOVERSION "${PROJECT_VERSION_MAJOR}" VERSION "${RAW_VERSION}")
    set_target_properties(driver PROPERTIES RUNTIME_OUTPUT_NAME "${LIBFILENAME}" LIBRARY_OUTPUT_NAME "${LIBFILENAME}" ARCHIVE_OUTPUT_NAME "${LIBFILENAME}")
    # Avoid generating shared libraries with version numbers in the filenames.
    set(CMAKE_PLATFORM_NO_VERSIONED_SONAME 1)
    # We must use these weird generator expressions to avoid the Debug and Release directories in VS: https://stackoverflow.com/q/47175912
    set_target_properties(driver PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin" LIBRARY_OUTPUT_DIRECTORY $<1:${CMAKE_CURRENT_BINARY_DIR}/lib> ARCHIVE_OUTPUT_DIRECTORY $<1:${CMAKE_CURRENT_BINARY_DIR}/lib>)

    # These paths are needed so that Khiops finds the driver.
    # 'RUNTIME DESTINATION' is used for DLLs on windows.
    if(DEFINED SKBUILD)
        install(TARGETS driver LIBRARY DESTINATION ${SKBUILD_DATA_DIR}/lib RUNTIME DESTINATION ${SKBUILD_SCRIPTS_DIR})
    else()
        install(TARGETS driver LIBRARY DESTINATION lib RUNTIME DESTINATION bin)
    endif()
endfunction()