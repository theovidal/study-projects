#ifndef SUDOKU_H
#define SUDOKU_H

#include <stdio.h>

#define N 3
#define N2 9
#define N4 81


int *read_grid(FILE *fp);

void print_grid(FILE *fp, int grid[N4]);

void print_grid_cnf(FILE *fp, int grid[N4]);

#endif
