cmake_minimum_required(VERSION 3.18)
project(estimate_pi LANGUAGES CXX CUDA)

set(CMAKE_CUDA_STANDARD 14)

set (files
    main.cu
    pi.cu
    pi.h
    error.h
)

add_executable(estimate_pi ${files})

target_link_libraries(estimate_pi PRIVATE curand)

target_compile_options(estimate_pi PRIVATE -O3 -Wall -Wextra)

add_custom_target(
    clang-format
    COMMAND clang-format -i ${files}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running clang-format on source files"
)
