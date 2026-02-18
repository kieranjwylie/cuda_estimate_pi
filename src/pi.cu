/**
 * @file pi.cu
 * @author Kieran Wylie
 * @brief Handles CUDA functions to estimate PI using monte-carlo. The kernel, along with the host function
 *        is handled here
 * @version 1.0
 * @date 2026-02-18
 */


#include "error.cuh"
#include <cuda_runtime.h> 
#include <curand_kernel.h>
#include <vector>


/** @brief Kernel to generate a set amount of random points and check how many are inside a quarter circle. The total number
 *         is fed back to the CPU. 
 * 
 *  @param d_counts: total number of counts of points inside the circle by this thread
 *  @param points_per_thread: total number of points for this thread to generate
 *  @param seed: random seed for curand to use
 */
__global__ void rand_pi(int *d_counts, int points_per_thread, unsigned long seed) {

  // Find unique thread index
  int idx = blockIdx.x * blockDim.x + threadIdx.x;

  // Initialise random state for each thread
  curandState state;
  curand_init(seed, idx, 0, &state);

  int count = 0;
  for (int i = 0; i < points_per_thread; i++) {
    float x = curand_uniform(&state);
    float y = curand_uniform(&state);

    if (x * x + y * y <= 1.0f)
      count++;
  }
  d_counts[idx] = count;
}

int output_device_props() {
  int device;
  cudaGetDevice(&device);

  cudaDeviceProp prop;
  CUDA_CHECK(cudaGetDeviceProperties(&prop, device));

  std::cout << "Device Name: " << prop.name << std::endl;
  std::cout << "Max Threads per Block: " << prop.maxThreadsPerBlock << std::endl;

  // Maximum threads per block in each dimension (x, y, z)
  std::cout << "Max threads per block dimension: " << prop.maxThreadsDim[0] << " x "
            << prop.maxThreadsDim[1] << " x " << prop.maxThreadsDim[2] << std::endl;

  // Maximum number of blocks in the grid (x, y, z)
  std::cout << "Max grid size (blocks per dimension): " << prop.maxGridSize[0] << " x "
            << prop.maxGridSize[1] << " x " << prop.maxGridSize[2] << std::endl;

  return 0;
}

int estimate_pi(int points_per_thread, int threads, int blocks, unsigned long seed,
                float *milliseconds, double *pi, long long *total_points) {
  // Take a record of time taken for calculation + memory transfer only
  cudaEvent_t start, stop;
  CUDA_CHECK(cudaEventCreate(&start));
  CUDA_CHECK(cudaEventCreate(&stop));

  int total_threads = threads * blocks;

  ///////////////////////////////////////////////////////////////////////////////////////////////
  CUDA_CHECK(cudaEventRecord(start));
  int *d_counts;
  CUDA_CHECK(cudaMalloc(&d_counts, total_threads * sizeof(int)));

  rand_pi<<<blocks, threads>>>(d_counts, points_per_thread, seed);

  std::vector<int> h_counts(total_threads);
  CUDA_CHECK(cudaMemcpy(h_counts, d_counts, total_threads * sizeof(int), cudaMemcpyDeviceToHost));

  long long total_in_circle = 0;
  for (int i = 0; i < total_threads; i++)
    total_in_circle += h_counts[i];

  *total_points = (long long)points_per_thread * total_threads;
  *pi = 4.0 * total_in_circle / *total_points;
  CUDA_CHECK(cudaEventRecord(stop));
  CUDA_CHECK(cudaEventSynchronize(stop));
  float ms = 0;
  CUDA_CHECK(cudaEventElapsedTime(&ms, start, stop));
  *milliseconds = ms;
  ///////////////////////////////////////////////////////////////////////////////////////////////

  CUDA_CHECK(cudaFree(d_counts));
  free(h_counts);

  return 0;
}