#!/usr/bin/env bash

# Setup
set -e

BUILD_DIR="$(pwd)/build/"
EXE_DIR="$BUILD_DIR/exe/cpu1"

make distclean
make prep
make -j$(nproc)
make install

pushd "$EXE_DIR"

sudo ./core-cpu1 --reset PO

popd
