/**
 * @file main.cpp
 * @author Kieran Wylie
 * @brief Main entry point for the Monte Carlo Pi estimation program. 
 *        Handles command line arguments, device property output, and calls the estimation function.
 * @version 1.0
 * @date 2026-02-18
 *
 * Supported command line arguments:
 * -t <threads>: Number of threads per block (default: 256)
 * -b <blocks>: Number of blocks in the grid (default: 256)
 * -p <points>: Number of points each thread will generate (default: 100)
 * -max: If present, outputs the maximum threads per block and grid size of the device and exits
 * 
 * Output format:
 * total threads, total points, estimated pi, error, time taken (in milliseconds)
 */

#include <iomanip>
#include <iostream>
#include <stdio.h>
#include <string>

#include "error.cuh"
#include "pi.cuh"

#define PI 3.14159265358979323846

/** 
  * @brief Reads command line arguments and sets the corresponding variables
  * 
  * Supported arguments: \n
  * -t <threads>: Number of threads per block (default: 256) \n
  * -b <blocks>: Number of blocks in the grid (default: 256) \n
  * -p <points>: Number of points each thread will generate (default: 100) \n
  * -max: If present, outputs the maximum threads per block and grid size of the device and exits \n
  * 
  * @param argc Argument count from main
  * @param argv Argument vector from main
  * @param threads Pointer to store the number of threads per block
  * @param blocks Pointer to store the number of blocks in the grid
  * @param points Pointer to store the number of points each thread will generate
  * @param output_max_threads Pointer to store whether to output max threads and exit
  * @return 0 on success, -1 on failure (e.g. unknown argument
  */
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