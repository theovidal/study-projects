#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <stdbool.h>
#include <string.h>
#include <inttypes.h>


typedef uint64_t T;

T *read_elements(FILE *fp, int *len, uint64_t *goal){
    fscanf(fp, "%d %" PRIu64, len, goal);
    uint64_t *elements = malloc(*len * sizeof(uint64_t));
    for (int i = 0; i < *len; i++) {
        fscanf(fp, "%" PRIu64, elements + i);
    }
    return elements;
}

void print_solution(FILE *fp, uint64_t elements[], int len, bool solution[]){
    for (int i = 0; i < len; i++){
        if (solution[i]) fprintf(fp, "%" PRIu64 " ", elements[i]);
    }
    fprintf(fp, "\n");
}



bool naive_decision(uint64_t arr[], int len, uint64_t goal) {
    if (len == 0) return false; // Aucune somme sur un tableau vide
    if (goal == 0) return true; // La somme vide donne 0, donc toujours satisfiable

    return naive_decision(&arr[1], len - 1, goal - arr[0]) || naive_decision(&arr[1], len - 1, goal);
}

bool naive_solution_aux(uint64_t arr[], int len, uint64_t goal, bool sol[]) {
    // Attention au sens des tests ! Si goal == 0, c'est gagné, donc il faut le privilégier

    if (goal == 0) return true; // La somme vide donne 0, donc toujours satisfiable
    if (len == 0) return false; // Aucune somme sur un tableau vide

    bool dec = naive_solution_aux(&arr[1], len - 1, goal - arr[0], &sol[1]);
    if (dec) sol[0] = true;
    return dec || naive_solution_aux(&arr[1], len - 1, goal, &sol[1]);
}

bool* naive_solution(uint64_t arr[], int len, uint64_t goal) {
    bool* sol = malloc(len * sizeof(bool));
    for (int i = 0; i < len; i++) {
        sol[i] = false;
    }
    if (naive_solution_aux(arr, len, goal, sol)) return sol;
    else {
        free(sol);
        return NULL;
    }
}

int main(int argc, char *argv[]) {
    int len;
    uint64_t S;
    uint64_t* arr;
    FILE* f_in = stdin;
    FILE* f_out = stdout;
    if (argc > 1) f_in = fopen(argv[1], "r");
    if (argc > 2) f_out = fopen(argv[2], "w");

    arr = read_elements(f_in, &len, &S);
    bool* sol = naive_solution(arr, len, S);
    if (sol == NULL) fprintf(f_out, "No");
    else {
        fprintf(f_out, "Yes\n");
        print_solution(f_out, arr, len, sol);
    }
    free(arr);
    if (sol != NULL) free(sol);
    return 0;
}
