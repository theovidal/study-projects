#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <pthread.h>
#include <stdbool.h>

#include "deque.h"


struct node {
    slice_t slice;
    struct node *next;
    struct node *prev;
};

typedef struct node node_t;

const slice_t DEFAULT = {.start = NULL, .len = 0};

struct deque {
    node_t *sentinel;
    pthread_mutex_t lock;
};

typedef struct deque deque_t;

node_t *new_node(slice_t data){
    node_t *n = malloc(sizeof(node_t));
    n->next = NULL;
    n->prev = NULL;
    n->slice = data;
    return n;
}

deque_t *new_deque(void){
    deque_t *q = malloc(sizeof(deque_t));
    q->sentinel = new_node(DEFAULT);
    q->sentinel->next = q->sentinel;
    q->sentinel->prev = q->sentinel;
    pthread_mutex_init(&q->lock, NULL);
    return q;
}

void free_deque(deque_t *q){
    pthread_mutex_lock(&q->lock);
    node_t *n = q->sentinel->next;
    while (n != q->sentinel) {
        node_t *tmp = n->next;
        free(n);
        n = tmp;
    }
    free(q->sentinel);
    pthread_mutex_unlock(&q->lock);
    pthread_mutex_destroy(&q->lock);
    free(q);
}

bool try_pop_left(deque_t *q, slice_t *result) {
    pthread_mutex_lock(&q->lock);
    node_t* el = q->sentinel->next;
    if (el == q->sentinel) {
        pthread_mutex_unlock(&q->lock);
        return false;
    }
    *result = el->slice;
    el->next->prev = el->prev;
    el->prev->next = el->next;
    pthread_mutex_unlock(&q->lock);
    free(el);
    return true;
}

bool try_pop_right(deque_t *q, slice_t *result) {
    // On lock bien AVANT de vérifier la vacuité
    pthread_mutex_lock(&q->lock);
    node_t* el = q->sentinel->prev;
    if (el == q->sentinel) {
        pthread_mutex_unlock(&q->lock);
        return false;
    }
    *result = el->slice;
    el->prev->next = el->next;
    el->next->prev = el->prev;
    pthread_mutex_unlock(&q->lock);
    free(el);
    return true;
}

void push_left(deque_t *q, slice_t data) {
    node_t* el = new_node(data);
    pthread_mutex_lock(&q->lock);
    el->prev = q->sentinel;
    el->next = q->sentinel->next;
    el->next->prev = el;
    el->prev->next = el;
    pthread_mutex_unlock(&q->lock);
}

void push_right(deque_t *q, slice_t data) {
    node_t* el = new_node(data);
    pthread_mutex_lock(&q->lock);
    el->next = q->sentinel;
    el->prev = q->sentinel->prev;
    el->next->prev = el;
    el->prev->next = el;
    pthread_mutex_unlock(&q->lock);
}


