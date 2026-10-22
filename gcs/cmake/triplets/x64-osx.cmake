set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME Darwin)
set(VCPKG_OSX_ARCHITECTURES x86_64)

# Overlay of vcpkg's built-in x64-osx triplet: keep dependency headers ahead of
# /usr/local/include (e.g. Homebrew fmt) when vcpkg builds ports such as spdlog.
list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS -DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON)
