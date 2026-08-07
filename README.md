# Khiops Drivers

This repository groups the Khiops cloud storage drivers for Azure, Google Cloud Storage, and Amazon S3 in a single source tree.

## Repository layout

- `azure/`: Azure driver sources, tests, scripts, and its dedicated `vcpkg` checkout
- `gcs/`: GCS driver sources, tests, scripts, and its dedicated `vcpkg` checkout
- `s3/`: S3 driver sources, tests, scripts, and its dedicated `vcpkg` checkout
- `src/`: code that is common to all drivers
- `test/`: tests that all drivers must pass

## Build entry point

The repository exposes a single top-level `CMakeLists.txt` and a single top-level `CMakePresets.json`.

The `azure-ninja-*`, `gcs-ninja-*`, and `s3-ninja-*` presets configure one driver at a time. This keeps the three dedicated `vcpkg` versions isolated for day-to-day development.

The `all-ninja-rel` preset enables the unified build and packaging flow for the three drivers.

Available configure presets:

- `azure-ninja-dbg`
- `azure-ninja-rel`
- `gcs-ninja-dbg`
- `gcs-ninja-rel`
- `s3-ninja-dbg`
- `s3-ninja-rel`
- `all-ninja-rel`

## Packaging

The root CMake project supports three build modes:

- developer builds with a single driver selected via `KHIOPS_DRIVER`
- pip packaging through `scikit-build-core`
- unified DEB and RPM packaging through `KHIOPS_PACKAGE_ALL=ON`

## Working on the drivers

On GNU/Linux, you can `source ./dev_aliases.sh` to load handy aliases into your current shell session.
The file [dev_aliases.sh](./dev_aliases.sh) contains aliases to:
- generate the build system with CMake
- build the drivers with CMake
- execute tests with CTest.

It will save you from typing CMake/CTest command-line arguments.

If you wish to run the tests of the Azure driver using the local Azurite storage emulator, which does support blob storage but not file share storage, you will have to define the following environment variables:
~~~ bash
AZURE_EMULATED_STORAGE=true
AZURE_STORAGE_CONNECTION_STRING='DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://localhost:10000/devstoreaccount1;'
STORAGE_DRIVER_TEST_URL_PREFIX=http://localhost:10000/devstoreaccount1/data-test-khiops-driver-azure
~~~
You may have to adapt the BlobEndpoint part of the `AZURE_STORAGE_CONNECTION_STRING` environment variable and also the `STORAGE_DRIVER_TEST_URL_PREFIX` environment variable if you configured Azurite with different values than its default configuration.