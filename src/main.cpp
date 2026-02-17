#include <curand_kernel.h>
#include <iomanip>
#include <iostream>
#include <stdio.h>
#include <string>

#include "error.h"
#include "pi.h"

#define PI 3.14159265358979323846

int read_command_line(int argc, char *argv[], int *threads, int *blocks, int *points,
                      bool *output_max_threads) {

  // Default values
  *threads = 256;
  *blocks = 256;
  *points = 100;
  *output_max_threads = false;

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
      std::cerr << "Unknown argument: " << arg << std::endl;
      return -1;
    }
  }

  return 0;
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

int main(int argc, char *argv[]) {
  int threads, blocks, points_per_thread;
  bool output_max_threads;
  float milliseconds;
  double pi;
  long long total_points;

  // Commmand line input, fails if invalid arguments are given
  CHECK_IERR(
      read_command_line(argc, argv, &threads, &blocks, &points_per_thread, &output_max_threads));

  // Optional output to stop running and display device properties
  if (output_max_threads) {
    CHECK_IERR(output_device_props());
    return 0;
  }

  // Main call to estimate pi
  CHECK_IERR(
      estimate_pi(points_per_thread, threads, blocks, 1234UL, &milliseconds, &pi, &total_points));

  // Output results in format:
  // total threads, total points, esimated pi, error, time taken
  double error = fabs(pi - PI);
  std::cout << std::setprecision(15) << std::fixed;
  std::cout << threads * blocks << ", " << total_points << ", " << pi << ", " << error << ", "
            << milliseconds << std::endl;

  return 0;
}