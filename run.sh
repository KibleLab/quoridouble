#!/bin/bash

# 빌드 디렉토리 생성 및 이동
mkdir -p build
cd build

# CMake 구성 및 빌드
cmake ..
make -j4

# 실행 파일 실행 (build 디렉토리에 있는 상태)
./rl_engine

# 빌드 디렉토리에서 나오기
cd ..