#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>

#include "clock.h"
#include "counter.h"
#include "deque.h"
#include "quicksort.h"
#include "utils.h"
#include "parallel_naive.h"
#include "global_list.h"
#include "work_stealing.h"

int compare(const void *x, const void *y){
    int a = *(int*)x;
    int b = *(int*)y;
    if (a < b) return -1;
    if (a > b) return 1;
    return 0;
}

int main(int argc, char *argv[]){
    if (argc != 4) {
        printf("Usage : %s nb_threads nb_elements nb_reps\n", argv[0]);
        return 1;
    }
    int nb_threads = atoi(argv[1]);
    int n = atoi(argv[2]);
    int nb_reps = atoi(argv[3]);
    int *arr = rand_array(n);
    int *copy = malloc(n * sizeof(int));
    memcpy(copy, arr, n * sizeof(int));
    int *sorted = malloc(n * sizeof(int));
    memcpy(sorted, arr, n * sizeof(int));
    qsort(sorted, n, sizeof(int), compare);
    printf("%d threads, initialization done\n", nb_threads);

    if (n <= 20) {print_array(arr, n, 1); print_array(sorted, n, 1);}

    double elapsed = 0.;
    for (int i = 0; i < nb_reps; i++) {
        timestamp t0 = gettime();
        parallel_sort_work_stealing(arr, n, nb_threads);
        timestamp t1 = gettime();
        if (n <= 20) {print_array(arr, n, 1); print_array(sorted, n, 1);}
        elapsed += delta_t(t0, t1);
        assert(equal(arr, sorted, n));
        memcpy(arr, copy, n * sizeof(int));
    }
    printf("Singlethreaded version\n");
    printf("Time per run: %.3fs\n", elapsed / nb_reps);
    printf("Time per element: %.1fns\n\n", 1e9 * elapsed / nb_reps / n);


    free(arr);
    free(copy);
    free(sorted);
    return 0;
}
