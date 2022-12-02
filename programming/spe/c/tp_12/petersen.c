#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <stdbool.h>

int counter = 0;

struct petersen {
    bool want[2];
    bool turn;
};

typedef struct petersen petersen;

petersen* m;

petersen* init(void) {
    petersen* p = malloc(sizeof(petersen));
    p->want[0] = false;
    p->want[1] = false;
    p->turn = false;
    return p;
}

void lock(petersen* mutex, bool thread) {
    mutex->want[thread] = true;
    mutex->turn = !thread;
    while(mutex->turn == !thread && mutex->want[!thread]) {}
}

void unlock(petersen* mutex, bool thread) {
    m->want[thread] = false;
}

void* multiple_increment(void* t) {
    bool thread = *(bool*)t;
    for (int i = 0; i < 2000000; i++) {
        lock(m, thread);
        counter++;
        unlock(m, thread);
    }
    return NULL;
}

int main(void) {
    m = init();

    pthread_t one;
    pthread_t two;
    bool arg1 = false;
    bool arg2 = true;
    pthread_create(&one, NULL, multiple_increment, &arg1);
    pthread_create(&two, NULL, multiple_increment, &arg2);
    pthread_join(one, NULL);
    pthread_join(two, NULL);
    printf("Counter: %d", counter);
    free(m);
}

