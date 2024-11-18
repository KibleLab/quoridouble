#!/bin/bash

# Reset Build Directory
rm -rf ./build
mkdir build
cd build

# Compile
cmake ..
make -j4

# Run
./agent