cmake_minimum_required(VERSION 3.10)

project(rl_engine)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

file(GLOB_RECURSE SOURCES 
    "src/*.cpp"
)

file(GLOB_RECURSE HEADERS
    "include/*.hpp"
)

# include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

add_executable(rl_engine ${SOURCES} ${HEADERS})

target_include_directories(rl_engine PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

