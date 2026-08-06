# Khiops Drivers

This repository groups the Khiops cloud storage drivers for Azure, Google Cloud Storage, and Amazon S3 in a single source tree.

## Repository layout

- `azure/`: Azure driver sources, tests, scripts, and its dedicated `vcpkg` checkout
- `gcs/`: GCS driver sources, tests, scripts, and its dedicated `vcpkg` checkout
- `s3/`: S3 driver sources, tests, scripts, and its dedicated `vcpkg` checkout
- `src/`: code common to all drivers
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