#!/usr/bin/env bash

# Setup
set -v
set -e

cd "$(dirname "$0")"

BUILD_DIR="$(pwd)/build/"
EXE_DIR="$BUILD_DIR/exe/cpu1"
NCPUS="$(nproc)"

echo $BUILD_DIR
echo $EXE_DIR
echo $NCPUS

make distclean
make config=debug prep
make -j$NCPUS
make install
zip -r crossbuildfiles.zip $BUILD_DIR
