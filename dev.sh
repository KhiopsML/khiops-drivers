# Feel free to "source" this file into your current shell session.
# It will save you some typing!
# Only for development purposes, since the driver libraries will be built in testing mode (and packaging will be disabled).

# Generate the build system (cmg = CMake Generate).
alias cmg-base='cmake --preset'
alias cmg-azure-dbg='cmg-base azure-dbg-testing'
alias cmg-azure-rel='cmg-base azure-rel-testing'
alias cmg-gcs-dbg='cmg-base gcs-dbg-testing'
alias cmg-gcs-rel='cmg-base gcs-rel-testing'
alias cmg-s3-dbg='cmg-base s3-dbg-testing'
alias cmg-s3-rel='cmg-base s3-rel-testing'
# Build (cmb = CMake Build).
alias cmb-base='cmake --build --preset'
alias cmb-azure-dbg='cmb-base azure-dbg-testing'
alias cmb-azure-rel='cmb-base azure-rel-testing'
alias cmb-gcs-dbg='cmb-base gcs-dbg-testing'
alias cmb-gcs-rel='cmb-base gcs-rel-testing'
alias cmb-s3-dbg='cmb-base s3-dbg-testing'
alias cmb-s3-rel='cmb-base s3-rel-testing'
# Run the tests, stopping on first failure (cmt = CMake Test).
alias cmt-base='ctest --stop-on-failure --preset'
alias cmt-azure-dbg-blob='cmt-base azure-dbg-testing-blob'
alias cmt-azure-rel-blob='cmt-base azure-rel-testing-blob'
alias cmt-azure-dbg-file='cmt-base azure-dbg-testing-file'
alias cmt-azure-rel-file='cmt-base azure-rel-testing-file'
alias cmt-gcs-dbg-blob='cmt-base gcs-dbg-testing-blob'
alias cmt-gcs-rel-blob='cmt-base gcs-rel-testing-blob'
alias cmt-s3-dbg-blob='cmt-base s3-dbg-testing-blob'
alias cmt-s3-rel-blob='cmt-base s3-rel-testing-blob'