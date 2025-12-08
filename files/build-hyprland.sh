#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/bin:$PATH

# Configurable variables (override via env if you like)
HYPR_REPO="${HYPR_REPO:-https://github.com/jakoolits/Hyprland.git}"
HYPR_REF="${HYPR_REF:-main}"   # you can set to a tag/commit/branch
BUILD_DIR="/usr/src/hyprland-build"

echo "==> Building Hyprland from ${HYPR_REPO} @ ${HYPR_REF}"

# Ensure the script is run as root in build stage
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Lightweight clone: depth=1 for faster builds; change if you need history
git clone --shallow-submodules --depth 1 --branch "${HYPR_REF}" "${HYPR_REPO}" "${BUILD_DIR}/src"

cd "${BUILD_DIR}/src"

# meson setup + ninja build
# Disable examples to reduce build size and time; change as needed
meson setup build --buildtype=release -Dexamples=false --prefix=/usr
ninja -C build
ninja -C build install

# Optional: strip binaries to reduce size (uncomment if desired)
# find /usr/bin /usr/lib -type f -exec file {} \; | grep ELF | cut -d: -f1 | xargs -r strip --strip-unneeded || true

# Cleanup sources to keep the image smaller
rm -rf "${BUILD_DIR}"

echo "==> Hyprland build/install completed"
