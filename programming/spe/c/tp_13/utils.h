#ifndef UTILS_H
#define UTILS_H

#include <stdbool.h>


void print_array(int* t, int len, int threshold);

int *rand_array(int len);

bool is_sorted(int *arr, int len);

bool equal(int *arr1, int *arr2, int len);

#endif
