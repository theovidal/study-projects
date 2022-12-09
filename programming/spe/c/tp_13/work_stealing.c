#include <stdlib.h>
#include <assert.h>
#include <pthread.h>
#include <stdbool.h>

#include "counter.h"
#include "deque.h"
#include "quicksort.h"
#include "global_list.h"

#define MIN_SIZE 1000

// À gauche : les plus récents
// A droite : les plus anciens
struct worker_data {
    deque_t **queues;
    counter_t *nb_tasks;
    int index;
    int nb_workers;
};

typedef struct worker_data worker_data_t;

static bool try_steal(worker_data_t *data, slice_t *slice) {
    for (int i = data->index + 1; i != data->index; i = (i + 1)%data->nb_workers) {
        if (try_pop_right(data->queues[i], slice)) return true;
    }
    return false;
}


static void process_task(worker_data_t *data, slice_t slice) {
    if (slice.len < MIN_SIZE) {
        full_sort(slice.start, slice.len);
        return;
    }
    int k = partition(slice.start, slice.len);
    slice_t left = {.start = slice.start, .len = k };
    slice_t right = {.start = &slice.start[k + 1], .len = slice.len - k - 1 };

    increment(data->nb_tasks);
    if (k >= slice.len - k - 1) {
        push_left(data->queues[data->index], left);
        full_sort(right.start, right.len);
    } else {
        push_left(data->queues[data->index], right);
        full_sort(left.start, left.len);
    }
}   


static void *worker(void *args) {
    worker_data_t* data = (worker_data_t*)args;
    while (get_counter(data->nb_tasks) > 0) {
        slice_t task;
        if (try_pop_left(data->queues[data->index], &task) || try_steal(data, &task)) {
            process_task(data, task);
            decrement(data->nb_tasks);
        }
    }
    return NULL;
}


void parallel_sort_work_stealing(int *arr, int len, int nb_threads) {
    pthread_t threads[nb_threads];
    deque_t** queues = malloc(nb_threads * sizeof(deque_t*));
    for (int i = 0; i < nb_threads; i++) {
        queues[i] = new_deque();
    }
    counter_t *nb_tasks = initialize_counter(1);
    worker_data_t* args = malloc(nb_threads * sizeof(worker_data_t));
    slice_t initial = {.start = arr, .len = len};
    push_right(queues[0], initial);
    for (int i = 0; i < nb_threads; i++) {
        worker_data_t arg = {.queues = queues, .nb_workers = nb_threads, .nb_tasks = nb_tasks, .index = i};
        args[i] = arg;
        pthread_create(&threads[i], NULL, worker, &args[i]);
    }
    for (int i = 0; i < nb_threads; i++) {
        pthread_join(threads[i], NULL);
    }
}
