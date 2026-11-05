find_package(azure-core-cpp CONFIG REQUIRED)
find_package(azure-identity-cpp CONFIG REQUIRED)
find_package(azure-storage-blobs-cpp CONFIG REQUIRED)
find_package(azure-storage-files-shares-cpp CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
add_library(khiops_driver_azure_objlib OBJECT
    auth.hpp
    blobpathresolve.cpp
    blobpathresolve.hpp
    connstr.cpp
    connstr.hpp
    core.cpp
    core.hpp
    driver.cpp
    filestream.cpp
    filestream.hpp
    globalstate.hpp
    sharepathresolve.cpp
    sharepathresolve.hpp
    specific_impl.cpp
    util.cpp
    util.hpp
)
target_link_libraries(khiops_driver_azure_objlib PUBLIC Azure::azure-core Azure::azure-identity Azure::azure-storage-blobs Azure::azure-storage-files-shares spdlog::spdlog khiops_driver_common)
set_target_properties(khiops_driver_azure_objlib PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(khiops_driver_azure SHARED)
target_link_libraries(khiops_driver_azure PRIVATE khiops_driver_azure_objlib)
set_target_properties(khiops_driver_azure PROPERTIES SOVERSION "${PROJECT_VERSION_MAJOR}" VERSION "${RAW_VERSION}")
if(TESTING)
    set(LIBFILENAME "libkhiopsdriver_file_azure_testing")
else()
    set(LIBFILENAME "libkhiopsdriver_file_azure")
endif()
set_target_properties(khiops_driver_azure PROPERTIES PREFIX "" RUNTIME_OUTPUT_NAME ${LIBFILENAME} LIBRARY_OUTPUT_NAME ${LIBFILENAME} ARCHIVE_OUTPUT_NAME ${LIBFILENAME})
# These paths are needed so that Khiops finds the driver.
# 'RUNTIME DESTINATION' is used for DLLs on windows.
if(DEFINED SKBUILD)
    install(TARGETS khiops_driver_azure LIBRARY DESTINATION ${SKBUILD_DATA_DIR}/lib RUNTIME DESTINATION ${SKBUILD_SCRIPTS_DIR})
else()
    install(TARGETS khiops_driver_azure LIBRARY DESTINATION lib RUNTIME DESTINATION bin)
endif()

configure_driver_package(
    khiops-driver-azure
    "Khiops driver to access files on Azure Cloud Storage"
    "The Azure driver plugin extends Khiops to enable processing of data files located on Azure Cloud Storage."
)