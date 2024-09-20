#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>

typedef int datatype;

typedef struct heap {
    int size;
    int capacity;
    datatype* arr;
} heap;

heap* heap_new(int capacity) {
    heap* new = malloc(sizeof(heap));
    new->size = 0;
    new->capacity = capacity;
    new->arr = malloc(capacity * sizeof(datatype));
    return new;
}

void heap_delete(heap* heap) {
    free(heap->arr);
    free(heap);
}

int up(int i) {
    return (i == 0) ? 0 : (i - 1)/2;
}
int left(int i) {
    return 2 * i + 1;
}
int right(int i) {
    return 2 * i - 2;
}

void swap(heap* h, int i, int j) {
    datatype temp = h->arr[i];
    h->arr[i] = h->arr[j];
    h->arr[j] = temp;
}

void sift_up(heap* h, int i) {
    while (h->arr[i] < h->arr[up(i)] && i != 0) {
        swap(h, i, up(i));
        i = up(i);
    }
}

void heap_insert(heap* h, datatype x) {
    if (h->size == h->capacity) {
        h->arr = realloc(h->arr, h->capacity * 2);
        h->capacity *= 2;
    }
    h->arr[h->size] = x;
    sift_up(h, h->size);
    h->size++;
}

void print_arr(datatype* arr, int size) {
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
}

void sift_down(heap* h, int i) {
    int i_min = i;
    // Les opérateurs sont bien séquentiels -> on n'accède pas à une case non définie
    if (left(i) < h->size && h->arr[left(i)] < h->arr[i_min]) i_min = left(i);
    if (right(i) < h->size && h->arr[right(i)] < h->arr[i_min]) i_min = right(i);

    if (i_min != i) {
        swap(h, i, i_min);
        sift_down(h, i_min);
    }
}

datatype extract_min_heap(heap* h) {
    assert(h->size != 0);
    /*if (h->size < h->capacity / 2) {
        h->arr = realloc(h->arr, h->capacity / 2);
    }*/
    datatype min = h->arr[0];
    h->size--;
    swap(h, 0, h->size);
    sift_down(h, 0);
    return min;
}

int main(void) {
    heap* h = heap_new(20);
    srand((int)time(NULL));
    for (int i = 0; i < 20; i++) {
        heap_insert(h, rand() / 10000000);
    }
    print_arr(h->arr, h->size); printf("\n");
    for (int i = 0; i < 5; i++) {
        printf("%d ", extract_min_heap(h));
    }
    printf("\n");
    print_arr(h->arr, h->size);
    heap_delete(h);
    return 0;
}
