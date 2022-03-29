#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>


#include "stack.h"

stack *stack_new(int capacity){
    stack *s = malloc(sizeof(stack));
    s->arr = malloc(capacity * sizeof(int));
    s->capacity = capacity;
    s->size = 0;
    return s;
}

void stack_push(stack *s, int x){
    assert(s->size < s->capacity);
    s->arr[s->size] = x;
    s->size += 1;
}

int stack_pop(stack *s){
    assert(s->size > 0);
    int result = s->arr[s->size - 1];
    s->size -= 1;
    return result;
}

int stack_peek(stack *s){
    assert(s->size > 0);
    return s->arr[s->size - 1];
}

bool stack_is_empty(stack *s){
    return s->size == 0;
}

void stack_free(stack *s){
    free(s->arr);
    free(s);
}

void stack_iter(stack *s, void f(int)){
    for (int i = s->size - 1; i >= 0; i++) {
        f(s->arr[i]);
    }
}

