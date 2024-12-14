# Project Initialize
cmake_minimum_required(VERSION 3.10)
project(quoridouble_agent)

# Set C++ Standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set Torch Path
file(TO_CMAKE_PATH "$ENV{HOME}/.torch/libtorch" TORCH_PATH)
set(CMAKE_PREFIX_PATH ${TORCH_PATH})

# Torch Package Initialize
find_package(Torch REQUIRED)

# Collect source files
file(GLOB_RECURSE SOURCES "src/*.cpp")
file(GLOB_RECURSE HEADERS "include/*.h" "include/*.hpp")

# Add Library
add_library(agent ${SOURCES})

# Include directories
target_include_directories(agent
    PUBLIC 
        ${CMAKE_CURRENT_SOURCE_DIR}/include  # 프로젝트의 헤더 파일
        ${TORCH_INCLUDE_DIRS}               # PyTorch 헤더 파일
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src     # 소스 파일 내부에서만 사용되는 헤더
)


target_compile_features(agent PUBLIC cxx_range_for)
target_link_libraries(agent ${TORCH_LIBRARIES})