# Khiops Drivers

This repository contains cloud storage drivers for the [Khiops](https://khiops.org/) AutoML suite.
There are drivers for:
- Microsoft Azure Cloud Storage;
- Google Cloud Storage (also known as GCS);
- Amazon S3 Cloud Storage.

Each driver is implemented as a cross-platform C++ library.
Each driver is a layer above the corresponding C++ cloud storage library, exposing the storage access functions as a shared library conforming to the Khiops storage driver interface.

## Features

Some functions exposed by the driver libraries mimics functions of C's standard library. Other mimics common shell commands.

| Feature                           | Azure driver | GCS driver | S3 driver |
| --------------------------------- | :----------: | :--------: | :-------: |
| Read/write access to remote blobs | ✔            | ✔          | ✔         |
| Read/write access to remote files | ✔            |            |           |
| Log to file or standard streams   | ✔            | ✔          | ✔         |

In addition, the Azure driver supports the Azurite storage emulator, which is limited to blob storage.

## Repository layout

- `azure/`: Azure driver sources, tests, scripts, and its dedicated `vcpkg` checkout
- `gcs/`: GCS driver sources, tests, scripts, and its dedicated `vcpkg` checkout
- `s3/`: S3 driver sources, tests, scripts, and its dedicated `vcpkg` checkout
- `src/`: code that is common to all drivers
- `test/`: tests that all drivers must pass

## Installing the drivers

The [Releases](https://github.com/KhiopsML/khiops-drivers/releases) page allows you to download the drivers in various package formats for various operating systems.
On [this page](https://khiops.org/setup), you can look for the drivers' section of the Khiops documentation for detailed installation instructions.
If Khiops is installed, the command `khiops -s` lists the installed drivers.

## Using the drivers

To use the drivers you need to authenticate to the cloud storage services you want to access; see the [authentication section](#authenticating-to-cloud-storage-services) for instructions.

The drivers can log to files or standard streams. This can be useful if you encounter difficulties using them. See the [logging section](#logging-to-files-or-standard-streams) for instructions.

### Authenticating to cloud storage services

This section explains how to authenticate to the cloud storage services supported by the drivers.
You will have to authenticate before using Khiops and its drivers, otherwise errors will arise, telling you that you do not have access to the remote data objects.

#### Authenticating to Microsoft Azure cloud storage services

The table below shows the supported methods of authentication.

| Authentication method         | Azurite storage emulator | Azure cloud storage |
| ----------------------------- | :----------------------: | :-----------------: |
| Connection string             | ✔                        | ✔                   |
| Environment credentials *     |                          | ✔                   |
| Workload identity credentials |                          | ✔                   |
| Managed identity credentials  |                          | ✔                   |
| Azure CLI credentials         |                          | ✔                   |

_* Client ID + client secret or certificate environment variables_

The documentation of the Azure CLI is [here](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest).
Its most basic authentication usage is a simple shell command: `az login`.

#### Authenticating to Google Cloud Storage services

In order to access the data stored on a GCS bucket, in most cases a valid authentication is required. The Khiops GCS driver by default uses the standard [Application Default Credentials](https://cloud.google.com/docs/authentication/provide-credentials-adc) authentication. This means that once you have valid credentials setup in your environment, Khiops will be using these exactly like your Python script or Google provided tools like gcloud or gsutil.

In order to setup your local environment with these credentials (assuming you have installed the [gcloud CLI](https://cloud.google.com/sdk/docs/install)), you will have to do the following:

    gcloud init
    gcloud auth application-default login

Voilà! You now have access to your data in GCS buckets!
The exact same authentication mechanism will allow a containerized Khiops script to run on the Google infrastructure.

#### Authenticating to Amazon S3 cloud storage services

In order to access the data stored on a S3 bucket, in most cases a valid authentication is required. Generally speaking, the Khiops S3 driver supports the same configuration options as the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html#welcome-versions-v2). More specifically, the Khiops S3 driver supports credentials and configuration options provided either via configuration files or environment variables - please refer to the Amazon documentation for the detailed explanations. This means that once you have valid credentials setup in your environment, Khiops will be using these exactly like your Python script or Amazon provided tools.

A typical file-based configuration is composed by the pair of `config` and `credentials` files located in the _$HOME/.aws_ folder.

`config`

    [default]
    region=us-east-1
    endpoint_url = https://my-server.cloudprovider.com

`credentials`

    [default]
    aws_access_key_id = AKIAIOSFODNN7EXAMPLE
    aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

Alternatively you can use pass the configuration options and credentials via environment variables:

    export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
    export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_ENDPOINT_URL=https://my-server.cloudprovider.com

Voilà! You now have access to your data in S3 buckets!

### Logging to files or standard streams

You can log information, warnings, errors and debug traces to a file using the following environment variables (they must both be defined to log anything):
- `<driver name>_DRIVER_LOGFILE`: path to the log file (which does not have to already exist);
- `<driver name>_DRIVER_LOGLEVEL`: available values are `off`, `critical`, `error`, `warning`, `info`, `debug`, `trace` (they are actually the values of the _spdlog_ logging library).
Replace `<driver name>` with the correct value depending on the driver from which you want the logs:

| Driver        | `<driver name>_DRIVER_LOGFILE` | `<driver name>_DRIVER_LOGLEVEL` |
| ------------- | ------------------------------ | ------------------------------- |
| Azure driver  | AZURE_DRIVER_LOGFILE           | AZURE_DRIVER_LOGLEVEL           |
| GCS driver    | GCS_DRIVER_LOGFILE             | GCS_DRIVER_LOGLEVEL             |
| S3 driver     | S3_DRIVER_LOGFILE              | S3_DRIVER_LOGLEVEL              |

You can define `<driver name>_DRIVER_LOGFILE` to be `/dev/stderr` or `/dev/stdout` if you want to log to standard error or standard output, respectively.

For example, if we want the Azure driver to log warnings and more critical information to stderr, we have to set two environment variables before using Khiops:
~~~ bash
export AZURE_DRIVER_LOGFILE=/dev/stderr
export AZURE_DRIVER_LOGLEVEL=warning
~~~

## Advanced usage

This section explains advanced usage such as building, packaging or working on the drivers.

Minimal C++ versions needed to compile each driver:

| Driver       | Minimal C++ version |
| ------------ | ------------------- |
| Azure driver | C++14               |
| GCS driver   | C++14               |
| S3 driver    | C++11               |

Testing library: GoogleTest.

CMake is used to generate the build systems for each driver.
CMake presets are available, using Ninja as the default generator.
Each driver must have its own build system because they have different vcpkg toolchains.
The reason for this is that they depend on different versions of vcpkg.
Thus, this repository contains three Git submodules, each referencing a different revision of vcpkg.

Building the drivers in debug mode on GNU/Linux enables sanitizers. This may be useful, for example, to detect memory leaks.

### Building the drivers

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

See the section [Working on the drivers](#working-on-the-drivers) for detailed instructions on how to build and test the drivers.

### Packaging the drivers

The root CMake project supports three build modes:

- developer builds with a single driver selected via `KHIOPS_DRIVER`
- pip packaging through `scikit-build-core`
- unified DEB and RPM packaging through `KHIOPS_PACKAGE_ALL=ON`

### Working on the drivers

#### Convenience shell aliases

On GNU/Linux, you can run `source ./dev_aliases.sh` to load handy aliases into your current shell session.
The file [dev_aliases.sh](./dev_aliases.sh) contains aliases to:
- generate the build system with CMake
- build the drivers with CMake
- execute tests with CTest.

It will save you from typing CMake/CTest command-line arguments.

#### Building and testing the drivers

It is convenient to use the CMake presets defined in the _CMakePresets.json_ file to build and test the drivers.
The presets will ease your work a lot by setting:
- the generator (Ninja);
- an output path that will avoid conflicts between drivers;
- the path to the toolchain file of the vcpkg revision that is specific to each driver;
- the path to the directory containing the vcpkg manifest file;
- the driver-specific URL prefix of the URLs used in tests;
- _and more..._

The `all-ninja-rel` preset is only intended for packaging purposes so you would normally not use it unless you are working on the packaging of the drivers.
If you are working on the packaging of the drivers, this is the only preset you should use.

This is an example workflow for the Azure driver:
1. Generate the build system with tests enabled (so that building will compile the tests too, not just the driver):
   ~~~ bash
   cmake --preset azure-ninja-dbg -DBUILD_TESTS=ON
   ~~~
2. Build the driver and the (previously enabled) tests, with parallelization enabled:
   ~~~ bash
   cmake --build --preset azure-ninja-dbg -j
   ~~~
3. Launch the tests, stopping on first failure, using the test blob storage service.
   ~~~ bash
   ctest --preset azure-ninja-dbg-blob --stop-on-failure
   ~~~

And now, the same with the help of the aliases:
1. Generate the build system with tests enabled (so that building will compile the tests too, not just the driver):
   ~~~ bash
   gen-azure-dbg
   ~~~
2. Build the driver and the (previously enabled) tests, with parallelization enabled:
   ~~~ bash
   build-azure-dbg
   ~~~
3. Launch the tests, stopping on first failure, using the test blob storage service.
   ~~~ bash
   test-azure-blob-dbg
   ~~~

#### Using the Azure driver with the Azurite storage emulator

If you wish to run the tests of the Azure driver using the local Azurite storage emulator, which does support blob storage but not file share storage, you will have to define the following environment variables:
~~~ bash
AZURE_EMULATED_STORAGE=true
AZURE_STORAGE_CONNECTION_STRING='DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://localhost:10000/devstoreaccount1;'
STORAGE_DRIVER_TEST_URL_PREFIX=http://localhost:10000/devstoreaccount1/data-test-khiops-driver-azure
~~~
You may have to adapt the BlobEndpoint part of the `AZURE_STORAGE_CONNECTION_STRING` environment variable and also the `STORAGE_DRIVER_TEST_URL_PREFIX` environment variable if you configured Azurite with different values than its default configuration.

Instead of the `azure-ninja-dbg-blob` and `azure-ninja-rel-blob` presets (not mentioning the file storage service presets because this kind of storage is not supported by the emulator), you can use `azure-ninja-dbg` and `azure-ninja-rel` because you will not need the predefined `STORAGE_DRIVER_TEST_URL_PREFIX` that points to the real Azure cloud storage.