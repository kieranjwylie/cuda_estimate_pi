#include <stdio.h>
#include <curand_kernel.h>
#include <string>
#include <iostream>
#include <iomanip>

#define PI 3.14159265358979323846

__global__ void estimate_pi(int *d_counts, int points_per_thread, unsigned long seed) {
    
    // Find unique thread index
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    // Initialise random state for each thread
    curandState state;
    curand_init(seed, idx, 0, &state);

    int count = 0;
    for (int i = 0; i < points_per_thread; i++) {
        float x = curand_uniform(&state);
        float y = curand_uniform(&state);
        
        if (x*x + y*y <= 1.0f) count++;
    }
    d_counts[idx] = count;
}

int read_command_line(int argc, char *argv[], int* threads, int* blocks, int* points, bool* output_max_threads) {

    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];

        if (arg == "-t") {
            *threads = atoi(argv[++i]);
        } else if (arg == "-b") {
            *blocks = atoi(argv[++i]);
        } else if (arg == "-p") {
            *points = atoi(argv[++i]);
        } else if (arg == "-max") {
            *output_max_threads = true;
        } else {
            fprintf(stderr, "Unknown argument: %s\n", arg.c_str());
            return -1;
        }
    }
    
    return 0;

}

int output_device_props() {
    int device;
    cudaGetDevice(&device);
    
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, device);
    
    std::cout << "Device Name: " << prop.name << std::endl;
    std::cout << "Max Threads per Block: " << prop.maxThreadsPerBlock << std::endl;

        // Maximum threads per block in each dimension (x, y, z)
    std::cout << "Max threads per block dimension: "
              << prop.maxThreadsDim[0] << " x "
              << prop.maxThreadsDim[1] << " x "
              << prop.maxThreadsDim[2] << std::endl;

    // Maximum number of blocks in the grid (x, y, z)
    std::cout << "Max grid size (blocks per dimension): "
              << prop.maxGridSize[0] << " x "
              << prop.maxGridSize[1] << " x "
              << prop.maxGridSize[2] << std::endl;

    return 0;
}

int main(int argc, char *argv[]) {    
    int threads, blocks, points_per_thread;
    bool output_max_threads = false;

    // Commmand line input, fails if invalid arguments are given
    int ierr = read_command_line(argc, argv, &threads, &blocks, &points_per_thread, &output_max_threads);
    if (ierr != 0) return ierr;

    // Optional output to stop running and display device properties
    if (output_max_threads) {
        output_device_props();
        return 0;
    }

    int total_threads = threads * blocks;

    // Take a record of time taken for calculation + memory transfer only
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    ///////////////////////////////////////////////////////////////////////////////////////////////
    cudaEventRecord(start);
    int *d_counts;
    cudaMalloc(&d_counts, total_threads * sizeof(int));

    estimate_pi<<<blocks, threads>>>(d_counts, points_per_thread, 1234UL);
    
    int *h_counts = (int*)malloc(total_threads * sizeof(int));
    cudaMemcpy(h_counts, d_counts, total_threads * sizeof(int), cudaMemcpyDeviceToHost);

    long long total_in_circle = 0;
    for (int i = 0; i < total_threads; i++) total_in_circle += h_counts[i];

    long long total_points = (long long)points_per_thread * total_threads;
    double pi = 4.0 * total_in_circle / total_points;
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    ///////////////////////////////////////////////////////////////////////////////////////////////


    // Output results in format:
    // total threads, total points, esimated pi, error, time taken
    double error = fabs(pi - PI);
    std::cout << std::setprecision(15) << std::fixed;
    std::cout << total_threads << ", " << total_points << ", " << pi << ", " << error << ", " << milliseconds << std::endl;

    cudaFree(d_counts);
    free(h_counts);

    return 0;
}