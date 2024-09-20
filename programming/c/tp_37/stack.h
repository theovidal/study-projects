#ifndef __STACK_H
#define __STACK_H

#include <stdbool.h>


struct stack {
    int *arr;
    int capacity;
    int size;
};

typedef struct stack stack;

// Returns a pointer to a new empty stack of a given capacity.
// That stack must eventually be freed through a call to stack_free.
stack *stack_new(int capacity);

void stack_free(stack *s);

bool stack_is_empty(stack *s);

// Adds x at the top of the stack : there has to be free capacity.
void stack_push(stack *s, int x);

// Pops and returns the element at the top of the stack (which
// has to be non-empty).
int stack_pop(stack *s);

// Returns the element at the top of the stack, without popping it.
// Stack has to be non-empty.
int stack_peek(stack *s);

// Calls f successively on each element of the stack, starting at
// the top. Does not modify the stack.
void stack_iter(stack *s, void f(int));

#endif

