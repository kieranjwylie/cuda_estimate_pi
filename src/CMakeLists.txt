cmake_minimum_required(VERSION 3.18)
project(estimate_pi LANGUAGES CXX CUDA)

set(CMAKE_CUDA_STANDARD 14)

add_executable(estimate_pi main.cu)

target_compile_options(estimate_pi PRIVATE -O3)