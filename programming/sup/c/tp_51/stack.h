#ifndef STACK_H
#define STACK_H

#include <stdint.h>

struct stack {
    int capacity;
    int size;
    uint8_t *data;
};

typedef struct stack stack;

stack *stack_new(int capacity);

void stack_free(stack *s);

int stack_size(stack *s);

uint8_t stack_pop(stack *s);

void stack_push(stack *s, uint8_t byte);


#endif
