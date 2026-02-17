#!/bin/bash

exe_loc=$PWD/../build/estimate_pi

if [ ! -f "$exe_loc" ]; then
    echo "Executable not found at $exe_loc. Please build the project first."
    exit 1
fi

blocks=(1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384)
threads=(1 2 4 8 16 32 64 128 256 512 1024)
num_points=(1 10 100 1000 10000 100000)
for b in "${blocks[@]}"; do
    for t in "${threads[@]}"; do
        for p in "${num_points[@]}"; do
            echo "Running with $b blocks, $t threads, and $p points..."
            $exe_loc -b $b -t $t -p $p >> results.csv
        done
    done
done