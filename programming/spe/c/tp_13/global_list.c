#include <stdlib.h>
#include <assert.h>
#include <pthread.h>
#include <stdbool.h>

#include "counter.h"
#include "deque.h"
#include "quicksort.h"
#include "global_list.h"

#define MIN_SIZE 1000

struct global_data {
    deque_t *queue;
    counter_t *nb_tasks;
};

typedef struct global_data global_data_t;


static void process_task(global_data_t *data, slice_t slice) {
    // TOUJOURS RETURN DANS CES CAS LÀ !!!!
    if (slice.len < MIN_SIZE) {
        full_sort(slice.start, slice.len);
        return;
    }
    int k = partition(slice.start, slice.len);
    slice_t left = {.start = slice.start, .len = k };
    slice_t right = {.start = &slice.start[k + 1], .len = slice.len - k - 1 };

    increment(data->nb_tasks);
    if (k >= slice.len - k - 1) {
        push_left(data->queue, left);
        full_sort(right.start, right.len);
    } else {
        push_left(data->queue, right);
        full_sort(left.start, left.len);
    }
}


static void *worker(void *args) {
    global_data_t* data = (global_data_t*)args;
    while (get_counter(data->nb_tasks) > 0) {
        slice_t task;
        // Ne pas mettre de while : on peut attendre une tâche alors que le compteur est repassé à 0 entre temps
        if (try_pop_right(data->queue, &task)) {
            process_task(data, task);
            decrement(data->nb_tasks);
        }
    }
    return NULL;
}


void parallel_sort_global(int *arr, int len, int nb_threads){
    pthread_t threads[nb_threads];
    deque_t *queue = new_deque();
    counter_t *nb_tasks = initialize_counter(1);
    global_data_t args = {.queue = queue, .nb_tasks = nb_tasks};
    slice_t initial = {.start = arr, .len = len};
    push_right(queue, initial);
    for (int i = 0; i < nb_threads; i++) {
        pthread_create(&threads[i], NULL, worker, &args);
    }
    for (int i = 0; i < nb_threads; i++) {
        pthread_join(threads[i], NULL);
    }
}
