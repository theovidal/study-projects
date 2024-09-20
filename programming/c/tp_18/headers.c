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
    heap[0] = 4;
    for (int i = 1; i < 5; i++) {
        heap[i] = 1;
    }
}

bool is_free(ui i) {
    return i > heap[0] || heap[i - 1] % 2 == 0;
}

ui read_size(ui i) {
    ui header = heap[i - 1];
    return (header % 2) * (-1) + header;
}

void set_free(ui i) {
    ui size = heap[i - 1] - 1;
    heap[i - 1] = size;
    heap[i + size] = size;
}

void set_used(ui i) {
    ui size = heap[i - 1];
    heap[i - 1] = size + 1;
    heap[i + size] = size + 1;
}

ui next(ui i) {
    ui size = heap[i - 1];
    if (size % 2 == 1) size -= 1;
    return i + size + 1;
}

ui previous(ui i) {
    // on est au prologue
    if (heap[i - 2] == 1) return i - 3;

    ui size = heap[i - 2];
    if (size % 2 == 1) size -= 1;

    return i - size - 1;
}

ui *malloc_ui(ui n) {
    
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
