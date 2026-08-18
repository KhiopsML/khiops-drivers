# Feel free to "source" this file into your current shell session.
# It will save you some typing!

### AZURE DRIVER ###
# Generate the build system with tests enabled.
alias gen-azure-dbg='cmake --preset azure-ninja-dbg -DBUILD_TESTS=ON'
alias gen-azure-rel='cmake --preset azure-ninja-rel -DBUILD_TESTS=ON'
# Build with parallelization enabled.
alias build-azure-dbg='cmake --build --preset azure-ninja-dbg -j'
alias build-azure-rel='cmake --build --preset azure-ninja-rel -j'
# Launch the tests, stopping on first failure, using the blob storage service.
alias test-azure-blob-dbg='ctest --preset azure-ninja-dbg-blob --stop-on-failure'
alias test-azure-blob-rel='ctest --preset azure-ninja-rel-blob --stop-on-failure'
# Launch the tests, stopping on first failure, using the file share storage service.
alias test-azure-file-dbg='ctest --preset azure-ninja-dbg-file --stop-on-failure'
alias test-azure-file-rel='ctest --preset azure-ninja-rel-file --stop-on-failure'

### GCS DRIVER ###
# Generate the build system with tests enabled.
alias gen-gcs-dbg='cmake --preset gcs-ninja-dbg -DBUILD_TESTS=ON'
alias gen-gcs-rel='cmake --preset gcs-ninja-rel -DBUILD_TESTS=ON'
# Build with parallelization enabled.
alias build-gcs-dbg='cmake --build --preset gcs-ninja-dbg -j'
alias build-gcs-rel='cmake --build --preset gcs-ninja-rel -j'
# Launch the tests, stopping on first failure.
alias test-gcs-dbg='ctest --preset gcs-ninja-dbg --stop-on-failure'
alias test-gcs-rel='ctest --preset gcs-ninja-rel --stop-on-failure'

### S3 DRIVER ###
# Generate the build system with tests enabled.
alias gen-s3-dbg='cmake --preset s3-ninja-dbg -DBUILD_TESTS=ON'
alias gen-s3-rel='cmake --preset s3-ninja-rel -DBUILD_TESTS=ON'
# Build with parallelization enabled.
alias build-s3-dbg='cmake --build --preset s3-ninja-dbg -j'
alias build-s3-rel='cmake --build --preset s3-ninja-rel -j'
# Launch the tests, stopping on first failure.
alias test-s3-dbg='ctest --preset s3-ninja-dbg --stop-on-failure'
alias test-s3-rel='ctest --preset s3-ninja-rel --stop-on-failure'