#include <stdlib.h>
#include <assert.h>

#include "vect.h"

struct vect {
    int capacity;
    int length;
    T *arr;
};

typedef struct vect* vect;

vect vect_make(void){
    vect v = malloc(sizeof(struct vect));
    v->length = 0;
    v->capacity = 0;
    v->arr = NULL;
    return v;
}

void vect_free(vect v){
    free(v->arr);
    free(v);
}

int vect_length(vect v){
    return v->length;
}

int vect_get(vect v, int i){
    assert (i >= 0 && i < v->length);
    return v->arr[i];
}

void vect_set(vect v, int i, int x){
    assert (i >= 0 && i < v->length);
    v->arr[i] = x;
}

int vect_pop(vect v){
    assert (v->length > 0);
    int x = v->arr[v->length - 1];
    v->length--;
    return x;
}

void _vect_resize(vect v, int new_capacity){
    int *new_arr = realloc(v->arr, new_capacity * sizeof(T));
    v->arr = new_arr;
    v->capacity = new_capacity;
}

void vect_push(vect v, int x){
    if (v->length == v->capacity) _vect_resize(v, 2 * v->capacity + 1);
    v->arr[v->length] = x;
    v->length++;
}
