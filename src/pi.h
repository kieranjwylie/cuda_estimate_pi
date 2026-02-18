/**
 * @file pi.h
 * @author Kieran Wylie
 * @brief Global caller function to use the GPU to estimate PI.
 * @version 1.0
 * @date 2026-02-18
 */

/** @brief Finds an estimate for PI using monte carlo
  * @param points_per_thread: total number of random points to generate
  * @param threads: number of threads per block to use for the kernel launch
  * @param blocks: number of blocks to use for the kernel launch
  * @param seed: seed for random number generation
  */
int estimate_pi(int points_per_thread, int threads, int blocks, unsigned long seed,
                float *milliseconds, double *pi, long long *total_points);