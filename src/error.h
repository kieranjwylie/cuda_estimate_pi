/**
 * @file error.h
 * @author Kieran Wylie
 * @brief Handles error checks for CUDA calls and standard function calls.
 * @version 1.0
 * @date 2026-02-18
 */

#include <cstdlib>
#include <iostream>

#define CHECK_IERR(ierr)                                                                           \
  do {                                                                                             \
    if (ierr != 0) {                                                                               \
      std::cerr << "Error: " << ierr << std::endl;                                                 \
      std::exit(EXIT_FAILURE);                                                                     \
    }                                                                                              \
  } while (0)


