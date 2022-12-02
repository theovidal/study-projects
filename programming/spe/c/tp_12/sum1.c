#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <math.h>

#include "clock.h"

pthread_mutex_t LOCK;


struct thread_args {
    double *arr;
    int len;
    double* sum;
};

typedef struct thread_args thread_args;


//
void *partial_sum_1(void *fun_args) {
    thread_args* args = (thread_args*)fun_args;
    for (int i = 0; i < args->len; i++) {
        *args->sum += args->arr[i];
    }
    return NULL;
}

void *partial_sum_2(void *fun_args) {
    thread_args* args = (thread_args*)fun_args;
    for (int i = 0; i < args->len; i++) {
        pthread_mutex_lock(&LOCK);
        *args->sum += args->arr[i];
        pthread_mutex_unlock(&LOCK);
    }
    return NULL;
}

void *partial_sum_3(void *fun_args) {
    thread_args* args = (thread_args*)fun_args;
    int s = 0.;
    for (int i = 0; i < args->len; i++) {
        s += args->arr[i];
    }
    pthread_mutex_lock(&LOCK);
    *args->sum += s;
    pthread_mutex_unlock(&LOCK);
    return NULL;
}

double *create_array(int len){
    double *arr = malloc(len * sizeof(double));
    for (int i = 0; i < len; i++) {
        arr[i] = sin(i);
    }
    return arr;
}

void print_array(double* arr, int len) {
    for (int i = 0; i < len; i++) {
        printf("%f", arr[i]);
        if (i < len - 1) printf(" - ");
    }
    printf("\n");
}

int main(int argc, char *argv[]){
    if (argc < 3) {
        printf("Spécifiez un nombre de threads et une taille de tableau");
        return -1;
    }
    pthread_mutex_init(&LOCK, NULL);
    int nb_threads = atoi(argv[1]);
    int len = atoi(argv[2]);
    double* arr = create_array(len);
    double sum = 0;

    pthread_t* threads = malloc(nb_threads * sizeof(pthread_t));
    thread_args* args = malloc(nb_threads * sizeof(thread_args));
    timestamp start = gettime();    
    for (int i = 0; i < nb_threads; i++) {
        int bound = i/(nb_threads - 1);
        args[i].arr = &arr[bound];
        args[i].len = bound + 1;
        args[i].sum = &sum;
        pthread_create(&threads[i], NULL, partial_sum_3, &args[i]);
    }
    for (int i = 0; i < nb_threads; i++) {
        pthread_join(threads[i], NULL);
    }
    timestamp end = gettime();

    printf("SUM: %f ; TIME: %f\n", sum, delta_t(start, end));

    free(arr);
    free(threads);
    pthread_mutex_destroy(&LOCK);
    return 0;
}
