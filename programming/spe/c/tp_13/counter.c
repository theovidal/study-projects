#include <pthread.h>
#include <stdlib.h>

struct counter {
    pthread_mutex_t lock;
    int value;
};

typedef struct counter counter_t;

counter_t *initialize_counter(int value){
    counter_t *counter = malloc(sizeof(counter_t));
    counter->value = value;
    pthread_mutex_init(&counter->lock, NULL);
    return counter;
}

void increment(counter_t *counter){
    pthread_mutex_lock(&counter->lock);
    counter->value++;
    pthread_mutex_unlock(&counter->lock);
}


void decrement(counter_t *counter){
    pthread_mutex_lock(&counter->lock);
    counter->value--;
    pthread_mutex_unlock(&counter->lock);
}

void set_counter(counter_t *counter, int value){
    pthread_mutex_lock(&counter->lock);
    counter->value = value;
    pthread_mutex_unlock(&counter->lock);
}

int get_counter(counter_t *counter){
    pthread_mutex_lock(&counter->lock);
    int result = counter->value;
    pthread_mutex_unlock(&counter->lock);
    return result;
}

void destroy_counter(counter_t *counter){
    pthread_mutex_destroy(&counter->lock);
    free(counter);
}
