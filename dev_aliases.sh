# Feel free to "source" this file into your current shell session.
# It will save you some typing!

### S3 DRIVER ###
# Generate the build system with tests enabled.
alias s3gendbg='cmake --preset s3-ninja-dbg -DBUILD_TESTS=ON'
alias s3genrel='cmake --preset s3-ninja-rel -DBUILD_TESTS=ON'
# Build with parallelization enabled.
alias s3builddbg='cmake --build --preset s3-ninja-dbg -j'
alias s3buildrel='cmake --build --preset s3-ninja-rel -j'
# Launch the tests, stopping on first failure.
alias s3testdbg='STORAGE_DRIVER_TEST_URL_PREFIX=s3://diod-data-di-jupyterhub ctest --preset s3-ninja-dbg --stop-on-failure'
alias s3testrel='STORAGE_DRIVER_TEST_URL_PREFIX=s3://diod-data-di-jupyterhub ctest --preset s3-ninja-rel --stop-on-failure'

### GCS DRIVER ###
# Generate the build system with tests enabled.
alias gcsgendbg='cmake --preset gcs-ninja-dbg -DBUILD_TESTS=ON'
alias gcsgenrel='cmake --preset gcs-ninja-rel -DBUILD_TESTS=ON'
# Build with parallelization enabled.
alias gcsbuilddbg='cmake --build --preset gcs-ninja-dbg -j'
alias gcsbuildrel='cmake --build --preset gcs-ninja-rel -j'
# Launch the tests, stopping on first failure.
alias gcstestdbg='STORAGE_DRIVER_TEST_URL_PREFIX=gs://data-test-khiops-driver-gcs ctest --preset gcs-ninja-dbg --stop-on-failure'
alias gcstestrel='STORAGE_DRIVER_TEST_URL_PREFIX=gs://data-test-khiops-driver-gcs ctest --preset gcs-ninja-rel --stop-on-failure'

### AZURE DRIVER ###
# Generate the build system with tests enabled.
alias azgendbg='cmake --preset azure-ninja-dbg -DBUILD_TESTS=ON'
alias azgenrel='cmake --preset azure-ninja-rel -DBUILD_TESTS=ON'
# Build with parallelization enabled.
alias azbuilddbg='cmake --build --preset azure-ninja-dbg -j'
alias azbuildrel='cmake --build --preset azure-ninja-rel -j'
# Launch the tests, stopping on first failure, using the local blob storage service emulator (Azurite).
alias azetestdbg="AZURE_EMULATED_STORAGE=true \
    AZURE_STORAGE_CONNECTION_STRING='DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://localhost:10000/devstoreaccount1;' \
    STORAGE_DRIVER_TEST_URL_PREFIX=http://localhost:10000/devstoreaccount1/data-test-khiops-driver-azure ctest --preset azure-ninja-dbg --stop-on-failure"
alias azetestrel="AZURE_EMULATED_STORAGE=true \
    AZURE_STORAGE_CONNECTION_STRING='DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://localhost:10000/devstoreaccount1;' \
    STORAGE_DRIVER_TEST_URL_PREFIX=http://localhost:10000/devstoreaccount1/data-test-khiops-driver-azure ctest --preset azure-ninja-rel --stop-on-failure"
# Launch the tests, stopping on first failure, using the real cloud blob storage service (Azure).
alias azbtestdbg='STORAGE_DRIVER_TEST_URL_PREFIX=https://khiopsdriverazure.blob.core.windows.net/data-test-khiops-driver-azure ctest --preset azure-ninja-dbg --stop-on-failure'
alias azbtestrel='STORAGE_DRIVER_TEST_URL_PREFIX=https://khiopsdriverazure.blob.core.windows.net/data-test-khiops-driver-azure ctest --preset azure-ninja-rel --stop-on-failure'
# Launch the tests, stopping on first failure, using the real cloud file share storage service (Azure).
alias azftestdbg='STORAGE_DRIVER_TEST_URL_PREFIX=https://khiopsdriverazure.file.core.windows.net/data-test-khiops-driver-azure ctest --preset azure-ninja-dbg --stop-on-failure'
alias azftestrel='STORAGE_DRIVER_TEST_URL_PREFIX=https://khiopsdriverazure.file.core.windows.net/data-test-khiops-driver-azure ctest --preset azure-ninja-rel --stop-on-failure'