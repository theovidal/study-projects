#ifndef MIN_HEAP
#define MIN_HEAP

#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <math.h>

typedef struct heap_node
{
    void *data;
    double weight;
    size_t index;
    size_t size;
} heap_node_t;


typedef struct min_heap_def
{
    heap_node_t* array;
    size_t capacity;
} min_heap;


// ----- Creation and deletion ----- //
min_heap mh_create(size_t n);
void mh_free(min_heap h);

// ----- Metadata inspection ----- //
bool mh_empty(min_heap h);
size_t mh_size(min_heap h);
size_t mh_capacity(min_heap h);

// ----- Move data in the structure ----- //
void mh_percolate_up(min_heap h, heap_node_t *n);
void mh_percolate_down(min_heap h, heap_node_t *n);
int mh_insert(min_heap h, double w, void* d);
void* mh_pop(min_heap h);
void mh_modify_weight(min_heap h,heap_node_t *n, double new_weight);

// Following functions are provided

// ----- Inspection ----- //
void* mh_get_data(heap_node_t*);

// ----- Iterator ----- //
heap_node_t* mh_first(min_heap h);
heap_node_t* mh_end(min_heap h);
heap_node_t* mh_next(min_heap h, heap_node_t* n);




#endif /* MIN_HEAP */
