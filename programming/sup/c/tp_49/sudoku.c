#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "sudoku.h"

int *read_grid(FILE *fp){
    int *grid = malloc(N4 * sizeof(int));
    for (int i = 0; i < N2; i++) {
        for (int j = 0; j < N2; j++) {
            int c;
            fscanf(fp, "%1d", &c);
            grid[i * N2 + j] = c;
        }
    }
    return grid;
}

void print_grid(FILE *fp, int grid[N4]){
    for (int i = 0; i < N2; i++) {
        for (int j = 0; j < N2; j++) {
            fprintf(fp, "%d ", grid[i * N2 + j]);
        }
        fprintf(fp, "\n");
    }
}

bool is_adjacent(int i, int j){
    int ix = i / N2;
    int iy = i % N2;
    int jx = j / N2;
    int jy = j % N2;
    return ix == jx || iy == jy || (ix / N2 == jx / N2 && iy / N2 == jy / N2);
}

int var(int i, int c){
    return i * N2 + c + 1;
}

void print_grid_cnf(FILE *fp, int grid[N4]){

    int nb_edges = 0;
    for (int i = 0; i < N4; i++) {
        for (int j = i + 1; j < N4; j++) {
            if (is_adjacent(i, j)) nb_edges++;
        }
    }

    // one clause per square plus one clause per edge per number
    int nb_clauses = N4 + N2 * nb_edges;
    // one variable per square per number
    int nb_variables = N4 * N2;
    fprintf(fp, "p cnf %d %d\n", nb_variables, nb_clauses);

    for (int i = 0; i < N4; i++){
        if (grid[i] != 0){
            fprintf(fp, "%d 0\n", var(i, grid[i]));
        }
        else {
            for (int c = 0; c < N2; c++) {
                fprintf(fp, "%d ", var(i, c));
            }
            fprintf(fp, "0\n");
        }
        for (int j = i + 1; j < N4; j++) {
            if (is_adjacent(i, j)) {
                for (int c = 0; c < N2; c++) {
                    fprintf(fp, "%d %d 0\n", -var(i, c), -var(j, c));
                }
            }
        }
    }
}
