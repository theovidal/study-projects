#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <time.h>


void print_array(int* t, int len, int threshold){
    for (int i = 0; i < len; i += threshold){
        printf("%d\n", t[i]);
    }
    printf("\n");
}


int *rand_array(int len){
    srand(time(0));
    int N = 1 << 28;
    int *t = malloc(len * sizeof(int));
    t[0] = rand() % N;
    for (int i = 1; i < len; i++){
        t[i] = (t[i - 1] + rand() % N) % N;
    }
    return t;
}

bool is_sorted(int *arr, int len){
    for (int i = 0; i < len - 1; i++){
        if (arr[i] > arr[i + 1]) return false;
    }
    return true;
}

bool equal(int *arr1, int *arr2, int len){
    for (int i = 0; i < len; i++) {
        if (arr1[i] != arr2[i]) return false;
    }
    return true;
}
