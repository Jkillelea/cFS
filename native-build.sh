#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

source native-build-vars.sh

BUILDDIR="$MISSIONCONFIG"

make O=$BUILDDIR distclean
make O=$BUILDDIR config=debug prep
bear make O=$BUILDDIR -j$(nproc)
make O=$BUILDDIR install

pushd "$BUILDDIR/exe/cpu1"
sudo ./core-cpu1 --reset PO
popd
