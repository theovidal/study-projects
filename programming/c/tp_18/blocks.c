#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

typedef uint64_t ui;

#define HEAP_SIZE 32
ui block_size = 8;

ui heap[HEAP_SIZE];

ui heap_index(ui* p){
    return p - heap;
}

void pre_initialize_heap(void){
    for (ui i = 0; i < HEAP_SIZE; i++){
        heap[i] = 0xFFFFFFFF;
    }
}

void print_heap(void){
    for (ui i = 0; i < HEAP_SIZE; i++){
        ui x = heap[i];
        if (x == 0xFFFFFFFF){
            printf("... ");
        } else {
            printf("%3llu ", (long long unsigned)x);
        }
    }
    printf("\n");
}

void set_memory(ui* p, ui size, ui value){
    for (ui i = 0; i < size; i++){
        p[i] = value;
    }
}

void init_heap(void) {
    heap[0] = 2;
}


bool is_free(ui i) {
    return i >= heap[0] || heap[i - 1] == 0;
}

void set_free(ui i) {
    heap[i - 1] = 0;
}

void set_used(ui i) {
    heap[i - 1] = 1;
}

ui *malloc_ui(ui n) {
    if (heap[0] + block_size > HEAP_SIZE || n > block_size) return NULL;

    // On parcourt tous les blocs jusqu'à en trouver un de libre
    ui i = 1;
    while (i < heap[0] && !is_free(i)) {
        i += block_size;
    }

    set_used(i);

    if (i == heap[0]) heap[0] += block_size;
    return &heap[i];
}

void free_ui(ui *p) {
    ui i = heap_index(p);
    set_free(i);
    if (heap[0] - block_size == i) heap[0] -= block_size;
}

int main(void){
    pre_initialize_heap();
    init_heap();

    ui* p1 = malloc_ui(6);
    ui* p2 = malloc_ui(3);
    set_memory(p1, 6, 42);
    set_memory(p2, 3, 52);

    print_heap();

    free_ui(p2);
    print_heap();
    return 0;
}