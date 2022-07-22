#!/usr/bin/env bash

if [ "$#" -ne 2 ]
then
    echo "Usage (note: only call inside xcode!):"
    echo "compile-library.sh <FFI_TARGET> <buildvariant>"
    exit 1
fi

# what to pass to cargo build -p, e.g. your_lib_ffi
FFI_TARGET=$1
# buildvariant from our xcconfigs
BUILDVARIANT=$2

RELFLAG=
if [[ "$BUILDVARIANT" != "debug" ]]; then
  RELFLAG=--release
fi

set -euvx

if [[ -n "${DEVELOPER_SDK_DIR:-}" ]]; then
  # Assume we're in Xcode, which means we're probably cross-compiling.
  # In this case, we need to add an extra library search path for build scripts and proc-macros,
  # which run on the host instead of the target.
  # (macOS Big Sur does not have linkable libraries in /usr/lib/.)
  export LIBRARY_PATH="${DEVELOPER_SDK_DIR}/MacOSX.sdk/usr/lib:${LIBRARY_PATH:-}"
fi

cbindgen --lang c --crate bajat-ffi --output ./include/ffibridge.h

# MacOS
$HOME/.cargo/bin/cargo build -p $FFI_TARGET --lib --release --target x86_64-apple-darwin
$HOME/.cargo/bin/cargo build -p $FFI_TARGET --lib --release --target aarch64-apple-darwin

# iOS Simulators
$HOME/.cargo/bin/cargo build -p $FFI_TARGET --lib --release --target x86_64-apple-ios
$HOME/.cargo/bin/cargo build -p $FFI_TARGET --lib --release --target aarch64-apple-ios-sim

# iOS
$HOME/.cargo/bin/cargo build -p $FFI_TARGET --lib --release --target aarch64-apple-ios

rm -rf ./bin/libbajat_ffi.xcframework
xcodebuild -create-xcframework \
  -library ./target/aarch64-apple-ios/release/libbajat_ffi.a \
  -headers ./include/ \
  -library ./target/aarch64-apple-ios-sim/release/libbajat_ffi.a \
  -headers ./include/ \
  -output ./bin/libbajat_ffi.xcframework
