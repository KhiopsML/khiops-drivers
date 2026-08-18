# Feel free to "source" this file into your current shell session.
# It will save you some typing!

### S3 DRIVER ###
# Generate the build system with tests enabled.
alias gens3dbg='cmake --preset s3-ninja-dbg -DBUILD_TESTS=ON'
alias gens3rel='cmake --preset s3-ninja-rel -DBUILD_TESTS=ON'
# Build with parallelization enabled.
alias builds3dbg='cmake --build --preset s3-ninja-dbg -j'
alias builds3rel='cmake --build --preset s3-ninja-rel -j'
# Launch the tests, stopping on first failure.
alias tests3dbg='ctest --preset s3-ninja-dbg --stop-on-failure'
alias tests3rel='ctest --preset s3-ninja-rel --stop-on-failure'

### GCS DRIVER ###
# Generate the build system with tests enabled.
alias gengcsdbg='cmake --preset gcs-ninja-dbg -DBUILD_TESTS=ON'
alias gengcsrel='cmake --preset gcs-ninja-rel -DBUILD_TESTS=ON'
# Build with parallelization enabled.
alias buildgcsdbg='cmake --build --preset gcs-ninja-dbg -j'
alias buildgcsrel='cmake --build --preset gcs-ninja-rel -j'
# Launch the tests, stopping on first failure.
alias testgcsdbg='ctest --preset gcs-ninja-dbg --stop-on-failure'
alias testgcsrel='ctest --preset gcs-ninja-rel --stop-on-failure'

### AZURE DRIVER ###
# Generate the build system with tests enabled.
alias genazuredbg='cmake --preset azure-ninja-dbg -DBUILD_TESTS=ON'
alias genazurerel='cmake --preset azure-ninja-rel -DBUILD_TESTS=ON'
# Build with parallelization enabled.
alias buildazuredbg='cmake --build --preset azure-ninja-dbg -j'
alias buildazurerel='cmake --build --preset azure-ninja-rel -j'
# Launch the tests, stopping on first failure, using the blob storage service.
alias testazureblobdbg='ctest --preset azure-ninja-dbg-blob --stop-on-failure'
alias testazureblobrel='ctest --preset azure-ninja-rel-blob --stop-on-failure'
# Launch the tests, stopping on first failure, using the file share storage service.
alias testazurefiledbg='ctest --preset azure-ninja-dbg-file --stop-on-failure'
alias testazurefilerel='ctest --preset azure-ninja-rel-file --stop-on-failure'