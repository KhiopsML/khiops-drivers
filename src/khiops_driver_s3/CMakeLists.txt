find_package(fmt CONFIG REQUIRED)
find_package(ZLIB REQUIRED)
find_package(AWSSDK CONFIG COMPONENTS s3 REQUIRED)
find_package(spdlog CONFIG REQUIRED)

set(SOURCES
    s3plugin.h
    s3plugin_internal.h
    s3plugin.cpp
)
list(TRANSFORM SOURCES PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/src/")

set(LINK_LIBS ${AWSSDK_LIBRARIES} spdlog::spdlog)

add_driver_library(libkhiopsdriver_file_s3 "${SOURCES}" "${AWSSDK_INCLUDE_DIRS}" "${LINK_LIBS}")

if(TESTING)
    add_subdirectory(specific_tests)
endif()

if(WIN32)
    if(DEFINED SKBUILD)
        install(CODE "
            file(GLOB dlls LIST_DIRECTORIES false \"${CMAKE_BINARY_DIR}/bin/*.dll\")
            if(NOT dlls)
                message(FATAL_ERROR \"Failed to find the DLLs of the dependencies in '${CMAKE_BINARY_DIR}/bin/' .\")
            endif()
            list(REMOVE_ITEM dlls \"${CMAKE_BINARY_DIR}/bin/libkhiopsdriver_file_s3.dll\")
            file(INSTALL DESTINATION ${SKBUILD_SCRIPTS_DIR} TYPE FILE FILES \${dlls})
        ")
    else()
        install(CODE "
            file(GLOB dlls LIST_DIRECTORIES false \"${CMAKE_BINARY_DIR}/bin/*.dll\")
            if(NOT dlls)
                message(FATAL_ERROR \"Failed to find the DLLs of the dependencies in '${CMAKE_BINARY_DIR}/bin/' .\")
            endif()
            list(REMOVE_ITEM dlls \"${CMAKE_BINARY_DIR}/bin/libkhiopsdriver_file_s3.dll\")
            file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/bin\" TYPE FILE FILES \${dlls})
        ")
    endif()
endif()