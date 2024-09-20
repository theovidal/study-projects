#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

typedef uint8_t T;

struct stack {
    int capacity;
    int size;
    T *data;
};

typedef struct stack stack;

stack *stack_new(int capacity){
    stack *s = malloc(sizeof(stack));
    s->capacity = capacity;
    s->size = 0;
    s->data = malloc(capacity * sizeof(T));
    return s;
}

void stack_free(stack *s){
    free(s->data);
    free(s);
}

int stack_size(stack *s){
    return s->size;
}

T stack_pop(stack *s){
    assert(s->size > 0);
    s->size--;
    return s->data[s->size];
}

void stack_push(stack *s, T byte){
    assert(s->size < s->capacity);
    s->data[s->size] = byte;
    s->size++;
}
