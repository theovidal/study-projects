#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>

int counter = 0;
pthread_mutex_t m;

void* multiple_increment(void*) {
    for (int i = 0; i < 2000000; i++) {
        pthread_mutex_lock(&m);
        counter++;
        pthread_mutex_unlock(&m);
    }
    return NULL;
}

int main(void) {
    pthread_mutex_init(&m, NULL);

    pthread_t one;
    pthread_t two;
    pthread_create(&one, NULL, multiple_increment, NULL);
    pthread_create(&two, NULL, multiple_increment, NULL);
    pthread_join(one, NULL);
    pthread_join(two, NULL);
    printf("Counter: %d", counter);
    pthread_mutex_destroy(&m);
}
