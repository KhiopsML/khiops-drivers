find_package(azure-core-cpp CONFIG REQUIRED)
find_package(azure-identity-cpp CONFIG REQUIRED)
find_package(azure-storage-blobs-cpp CONFIG REQUIRED)
find_package(azure-storage-files-shares-cpp CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
if(BUILD_TESTS)
    find_package(fmt CONFIG REQUIRED)
    find_package(Boost REQUIRED)
endif()

set(SOURCES
    auth.hpp
    blobpathresolve.hpp
    blobpathresolve.cpp
    connstr.hpp
    connstr.cpp
    core.hpp
    core.cpp
    driver.cpp
    filestream.hpp
    filestream.cpp
    globalstate.hpp
    sharepathresolve.hpp
    sharepathresolve.cpp
    specific_impl.cpp
    util.hpp
    util.cpp
    version.hpp
)
list(TRANSFORM SOURCES PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/src/khiops_driver_azure/")

set(LINK_LIBS
    Azure::azure-core
    Azure::azure-identity
    Azure::azure-storage-blobs
    Azure::azure-storage-files-shares
    spdlog::spdlog
)
if(WIN32)
    list(APPEND LINK_LIBRARIES bcrypt)
endif()

add_driver(libkhiopsdriver_file_azure "${SOURCES}" "" "${LINK_LIBS}")