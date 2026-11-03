# CHANGELOG

## vX.Y.Z - YYYY-MM-DD

- Removed generation of Debian 11 Bullseye package because Debian 11 is end-of-life.

- Added generation of Ubuntu 26.04 Resolute Raccoon packages for AMD64 and ARM64 architectures.

- Fixed support for suffixed version numbers (for example: `0.0.32-a.1`).

  > Previously, suffixes were allowed, but, with the exception of Python packaging, they were removed from the package version numbers.

- Removed unused CI workflow `hosted-pure-workflow.yml`.

- Renamed CI workflow `hosted-ninja-vcpkg_submod` to `test`.

- Renamed CI workflow `packaging` to `package`.

- The container images used to run DEB and RPM package tests (`test-deb` and `test-rpm` jobs of `package.yml` workflow) are now generic images instead of specific KhiopsML build images.

- Package generation now starts by checking the version number.

  > We check that the version number is in the file *src/khiops_driver_common/version.hpp*.
  > Moreover, if we are on a tag, we check that the tag name is equal to the version number that is in the file.

- Custom artifact display (`artifacts-summary` job of `package.yml` workflow) is now executed only if all `build-*` jobs succeeded.

  > Previously, this job was always executed, even in case part of the `build-*` jobs failed, which was not necessarily useful.
  
  > As a reminder, this job allows listing the artifacts together with their download links, even when the GitHub web UI fails to do so.

- The Python packages do not require a specific Python version anymore (since the driver libraries are written in C++).

- The binary Python packages (wheels) are now built in environments using CPython 3.11 instead of CPython 3.9.

- Updated the *scikit-build-core* build system used to generate the Python packages.

- Updated all GitHub actions which had a newer version available.

- Updated the Python version used in CI jobs of the `package.yml` workflow to `3.15.2`.

  > Python is used in the `test-pip` job to create a virtual environment and to install Khiops Core and Khiops drivers.

  > Python is used it the `test-zip` job to create a virtual environment and to install Khiops Core.