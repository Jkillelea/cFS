#!/usr/bin/env bash

cd "$(dirname "$0")"

source arm-build-vars.sh

BUILDDIR="$HOME/$MISSIONCONFIG"

make O=$BUILDDIR distclean
make O=$BUILDDIR config=debug prep
make O=$BUILDDIR -j$(nproc)
make O=$BUILDDIR install
