#!/bin/bash
set -e

apt-get update --fix-missing && \
    apt-get install -y gawk make build-essential clang llvm git wget ninja-build cmake libboost-all-dev


apt-get install -y python3 python3-dev python3-pip
pip3 install --upgrade pip
pip3 install networkx
pip3 install pydot
pip3 install pydotplus
