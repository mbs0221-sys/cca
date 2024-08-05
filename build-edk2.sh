#!/bin/bash

pushd edk2

# prepare
git submodule update --init
make -C BaseTools
source edksetup.sh
export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-

# debug
# build -a AARCH64 -t GCC5 -p ArmVirtPkg/ArmVirtQemuKernel.dsc -b DEBUG
# release
build -a AARCH64 -t GCC5 -p ArmVirtPkg/ArmVirtQemuKernel.dsc -b RELEASE

popd