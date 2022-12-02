#include <stdio.h>
#include <pthread.h>

#define NB_THREADS 2

void *f(void *arg){
    int index = *(int*)arg;
    for (int i = 0; i < 10; i++) {
        printf("Thread %d : %d\n", index, i);
    }
    return NULL;
}

int main(void){
    pthread_t threads[NB_THREADS];
    int index[NB_THREADS];
    printf("Before creating the threads.\n");
    for (int i = 0; i < NB_THREADS; i++) {
        index[i] = i;
        pthread_create(&threads[i], NULL, f, &index[i]);
    }
    printf("While the other threads are running.\n");
    for (int i = 0; i < NB_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }
    printf("After the other threads have stopped running.\n");
    return 0;
}

int main_(void){
    pthread_t threads[NB_THREADS];
    int args[NB_THREADS];
    printf("Before creating the threads.\n");
    for (int i = 0; i < NB_THREADS; i++) {
        args[i] = i;
        pthread_create(&threads[i], NULL, f, &args[i]);
    }
    printf("While the other threads are running.\n");
    for (int i = 0; i < NB_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }
    printf("After the other threads have stopped running.\n");
    return 0;
}
