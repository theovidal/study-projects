#ifndef DEQUE_H
#define DEQUE_H

#include <stdbool.h>

struct slice {
    int *start;
    int len;
};

typedef struct slice slice_t;

typedef struct node node_t;

typedef struct deque deque_t;

deque_t *new_deque(void);

bool try_pop_left(deque_t *q, slice_t *result);

bool try_pop_right(deque_t *q, slice_t *result);

void push_left(deque_t *q, slice_t data);

void push_right(deque_t *q, slice_t data);


void free_deque(deque_t *q);

#endif
