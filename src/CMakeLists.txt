cmake_minimum_required(VERSION 3.18)
project(estimate_pi LANGUAGES CXX CUDA)

set(CMAKE_CUDA_STANDARD 14)

set (files
    main.cpp
    pi.cu
    pi.h
    error.h
)

add_executable(estimate_pi ${files})

target_compile_options(estimate_pi PRIVATE -O3 -Wall -Wextra)