#!/bin/bash
set -e

apt-get update --fix-missing && \
    apt-get install -y gawk make build-essential git wget ninja-build cmake libboost-all-dev
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -

echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-11 main" >> /etc/apt/sources.list
echo "deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-11 main" >> /etc/apt/sources.list

apt-get update
# LLVM
apt-get install -y libllvm-11-ocaml-dev libllvm11 llvm-11 llvm-11-dev llvm-11-doc llvm-11-examples llvm-11-runtime
# Clang and co
apt-get install -y clang-11 clang-tools-11 clang-11-doc libclang-common-11-dev libclang-11-dev libclang1-11 clang-format-11 clangd-11
# libfuzzer
apt-get install -y libfuzzer-11-dev
# lldb
apt-get install -y lldb-11
# lld (linker)
apt-get install -y lld-11
# libc++
apt-get install -y libc++-11-dev libc++abi-11-dev
# OpenMP
apt-get install -y libomp-11-dev


update-alternatives \
  --install /usr/lib/llvm              llvm             /usr/lib/llvm-11  20 \
  --slave   /usr/bin/llvm-config       llvm-config      /usr/bin/llvm-config-11  \
    --slave   /usr/bin/llvm-ar           llvm-ar          /usr/bin/llvm-ar-11 \
    --slave   /usr/bin/llvm-as           llvm-as          /usr/bin/llvm-as-11 \
    --slave   /usr/bin/llvm-bcanalyzer   llvm-bcanalyzer  /usr/bin/llvm-bcanalyzer-11 \
    --slave   /usr/bin/llvm-c-test       llvm-c-test      /usr/bin/llvm-c-test-11 \
    --slave   /usr/bin/llvm-cov          llvm-cov         /usr/bin/llvm-cov-11 \
    --slave   /usr/bin/llvm-diff         llvm-diff        /usr/bin/llvm-diff-11 \
    --slave   /usr/bin/llvm-dis          llvm-dis         /usr/bin/llvm-dis-11 \
    --slave   /usr/bin/llvm-dwarfdump    llvm-dwarfdump   /usr/bin/llvm-dwarfdump-11 \
    --slave   /usr/bin/llvm-extract      llvm-extract     /usr/bin/llvm-extract-11 \
    --slave   /usr/bin/llvm-link         llvm-link        /usr/bin/llvm-link-11 \
    --slave   /usr/bin/llvm-mc           llvm-mc          /usr/bin/llvm-mc-11 \
    --slave   /usr/bin/llvm-nm           llvm-nm          /usr/bin/llvm-nm-11 \
    --slave   /usr/bin/llvm-objdump      llvm-objdump     /usr/bin/llvm-objdump-11 \
    --slave   /usr/bin/llvm-ranlib       llvm-ranlib      /usr/bin/llvm-ranlib-11 \
    --slave   /usr/bin/llvm-readobj      llvm-readobj     /usr/bin/llvm-readobj-11 \
    --slave   /usr/bin/llvm-rtdyld       llvm-rtdyld      /usr/bin/llvm-rtdyld-11 \
    --slave   /usr/bin/llvm-size         llvm-size        /usr/bin/llvm-size-11 \
    --slave   /usr/bin/llvm-stress       llvm-stress      /usr/bin/llvm-stress-11 \
    --slave   /usr/bin/llvm-symbolizer   llvm-symbolizer  /usr/bin/llvm-symbolizer-11 \
    --slave   /usr/bin/llvm-tblgen       llvm-tblgen      /usr/bin/llvm-tblgen-11 \
    --slave   /usr/bin/opt               opt              /usr/lib/llvm-11/bin/opt

update-alternatives \
  --install /usr/bin/clang                 clang                  /usr/bin/clang-11     20 \
  --slave   /usr/bin/clang++               clang++                /usr/bin/clang++-11 \
  --slave   /usr/bin/clang-cpp             clang-cpp              /usr/bin/clang-cpp-11



apt-get install -y python3 python3-dev python3-pip
pip3 install --upgrade pip
pip3 install networkx
pip3 install pydot
pip3 install pydotplus
