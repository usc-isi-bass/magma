#!/bin/bash
set -e

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
##

if [ ! -d "$FUZZER/repo" ]; then
    echo "fetch.sh must be executed first."
    exit 1
fi

export CC=clang
export CXX=clang++

pushd $FUZZER/repo
make clean all
pushd llvm_mode; make clean all; popd
pushd distance_calculator; cmake -G Ninja ./; cmake --build ./; popd

# compile afl_driver.cpp
"./afl-clang-fast++" $CXXFLAGS -std=c++11 -c "afl_driver.cpp" -fPIC -o "$OUT/afl_driver.o"
popd
