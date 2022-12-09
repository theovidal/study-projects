#include <pthread.h>
#include <stdlib.h>

struct counter {
    pthread_mutex_t lock;
    int value;
};

typedef struct counter counter_t;

counter_t *initialize_counter(int value);

void increment(counter_t *counter);

void decrement(counter_t *counter);

void set_counter(counter_t *counter, int value);

int get_counter(counter_t *counter);

void destroy_counter(counter_t *counter);
