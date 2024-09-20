#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <stdbool.h>
#include <string.h>
#include <inttypes.h>

typedef uint64_t set_t;

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

void compute_sums(T arr[], set_t set, int i, T sum, T* sums) {
    if (i < 0) {
        sums[set] = sum;
        return;
    }

    compute_sums(arr, set | (1ull << i), i - 1, sum + arr[i], sums);
    compute_sums(arr, set, i - 1, sum, sums);
}

bool exists_sum(T goal, T sA[], int n, T sB[], int p) {
    T sizeA = 1ull << n;
    T sizeB = 1ull << p;
    if (n == 0 || p == 0) return false;
    // Solution DS.2 : on réduit les indices d'un côté et de l'autre en fonction de si la somme est trop grande ou trop petite

    int i = 0;
    int j = sizeB - 1;
    while (i < sizeA && j > 0) {
        T s = sA[i] + sB[j];
        if (s == goal) return true;
        else if (s < goal) i++;
        else j--;
    }
    
    return false;
}

int compare_uint64(const void *a, const void *b) {
    uint64_t x = *(const uint64_t*)a;
    uint64_t y = *(const uint64_t*)b;
    if (x < y) return -1;
    if (x > y) return 1;
    return 0;
}

void sort_sums(T arr[], int len) {
    qsort(arr, len, sizeof(uint64_t), compare_uint64);
}

bool decision(T arr[], int len, T goal) {
    printf("%d\n", (1 << len));
    uint64_t* sumA = malloc((1 << len) * sizeof(uint64_t));
    uint64_t* sumB = malloc((1 << len) * sizeof(uint64_t));
    for (int i = 0; i < len; i++) {
        compute_sums(arr, i, len / 2, 0, sumA);
        compute_sums(&arr[len/2], i, (len + 1)/2 + 1, 0, sumB);
    }

    return exists_sum(goal, sumA, len, sumB, len);
}

int main(int argc, char* argv[]) {
    int len;
    uint64_t S;
    uint64_t* arr;
    FILE* f_in = stdin;
    FILE* f_out = stdout;
    if (argc > 1) f_in = fopen(argv[1], "r");
    if (argc > 2) f_out = fopen(argv[2], "w");

    arr = read_elements(f_in, &len, &S);

    if (decision(arr, len, S)) fprintf(f_out, "Yes\n");
    else fprintf(f_out, "No\n");
    return 0;
}
