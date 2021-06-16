#!/usr/bin/env bash

# Setup
set -e

BUILD_DIR="$(pwd)/build/"
EXE_DIR="$BUILD_DIR/exe/cpu1"
NCPUS="$(nproc)"

make distclean
make config=debug prep
bear make -j$NCPUS
make install

pushd "$EXE_DIR"
sudo ./core-cpu1 --reset PO
popd
