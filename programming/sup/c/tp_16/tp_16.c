#include <stdio.h>
#include <stdlib.h>
#include <assert.h>


/* Partie 2 */

struct int_array {
    int len;
    int* data;
};

typedef struct int_array int_array;

int_array* array_create(int len, int x){

    int_array* t = malloc(sizeof(int_array));
    int* data = (int*)malloc(len * sizeof(int));

    for (int i = 0; i < len; i++){
        data[i] = x;
    }
    t->len = len;
    t->data = data;

    return t;
}


int array_get(int_array* t, int i) {
    assert(i < t->len);
    return t->data[i];
}

void array_set(int_array* t, int i, int x) {
    assert(i < t->len);
    t->data[i] = x;
}

void array_delete(int_array* t) {
    free(t->data);
    free(t);
}

void array_print(int_array* t){
    for (int i = 0; i < t->len; i++){
        printf("%d ", array_get(t, i));
    }
    printf("\n");
}

int array_sum(int_array* t){
    int n = t->len;
    int s = 0;
    for (int i = 0; i < n; i++){
        s += array_get(t, i);
    }
    return s;
}

void test_partie_2(void){
    int size = 100;
    int_array* t = array_create(size, 3);
    assert(array_sum(t) == 3 * size);
    int n = t->len;
    for (int i = 0; i < n; i++){
        array_set(t, i, array_get(t, i) + i);
    }
    assert(array_sum(t) == 3 * size + size * (size - 1) / 2);
    array_delete(t);
}


/************/
/* Partie 3 */
/************/

struct int_dynarray {
    int len;
    int capacity;
    int* data;
};

typedef struct int_dynarray int_dynarray;



/* Partie 3.1 */

int length(int_dynarray* t) {
    return t->len;
}

int_dynarray* make_empty(void) {
    int_dynarray* t = (int_dynarray*)malloc(sizeof(int_dynarray));
    t->len = 0;
    t->capacity = 0;
    t->data = NULL;
    return t;
}

int get(int_dynarray* t, int i) {
    assert(i < t->len);
    return t->data[i];
}

void set(int_dynarray* t, int i, int x) {
    assert(i < t->len);
    t->data[i] = x;
}

void resize(int_dynarray* t, int new_capacity) {
    if (t->data == NULL) {
        t->data = (int*)malloc(new_capacity * sizeof(int));
    } else {
        t->data = (int*)realloc(t->data, new_capacity * sizeof(int));
    }
    t->capacity = new_capacity;
    if (new_capacity < t->len) { // Prendre en compte les réductions de capacité qui tronquent le tableau
        t->len = new_capacity;
    }
}

int pop_naif(int_dynarray* t) {
    assert(t->len > 0);
    int x = t->data[t->len - 1];
    t->len--;
    return x;
}

void push_naif(int_dynarray* t, int x) {
    t->len++;
    if (t->len > t->capacity) {
        resize(t, t->capacity + 1);
    }
    t->data[t->len - 1] = x;
}

void delete(int_dynarray* t) {
    free(t->data);
    free(t);
}


// Pour tester

void print(int_dynarray* t){
    int n = length(t);
    for (int i = 0; i < n; i++){
        printf("%d ", get(t, i));
    }
    printf("\n");
}

void test_partie_3() {
    int_dynarray* t = make_empty();
    resize(t, 5);
    push_naif(t, 12);
    push_naif(t, 5);
    push_naif(t, 3);
    print(t);
    resize(t, 2);
    int x = pop_naif(t);
    print(t);
    printf("%d\n", x);
    delete(t);
}


/* Partie 3.2 */

void push(int_dynarray* t, int x) {
    t->len++;
    if (t->len > t->capacity) {
        resize(t, t->capacity * 2);
    }
    t->data[t->len - 1] = x;
}

int pop(int_dynarray* t) {
    assert(t->len > 0);
    int x = t->data[t->len - 1];
    
    t->len--;
    if (t->len < t->capacity / 2) {
        resize(t, t->capacity / 2);
    }

    return x;
}


/* Partie 3.3 */

void insert_at(int_dynarray* t, int i, int x) {
    push(t, get(t, length(t) - 1));
    for (int n = length(t) - 2; n > i; n--) {
        set(t, n, get(t, n-1));
    }
    set(t, i, x);
}

int pop_at(int_dynarray* t, int i) {
    int x = get(t, i);
    for (int n = length(t) - 1; n > i; n--) {
        set(t, n-1, get(t, n));
    }
    pop(t);
    return x;
}

void test_partie_3_bis() {
    int_dynarray* t = make_empty();
    resize(t, 1);
    push(t, 2);
    push(t, 4);
    push(t, 5);
    insert_at(t, 1, 3);
    print(t);
    printf("%d\n", pop_at(t, 2));
    print(t);
    delete(t);
}

int position_linear(int_dynarray* t, int x) {
    int i = 0;
    while (i < length(t)) {
        if (get(t, i) > x) return i;
        i++;
    }
    return i;
}

int position(int_dynarray* t, int x);

int_dynarray* insertion_sort(int_dynarray* t) {
    int_dynarray* out = make_empty();
    resize(out, length(t));
    push(out, get(t, length(t) - 1));
    for (int i = 0; i < length(t); i++) {
        int x = get(t, i);
        int index = position_linear(out, x);
        insert_at(out, index, x);
    }
    return out;
}

void test_tri() {
    int_dynarray* t = make_empty();
    resize(t, 1);
    push(t, 12);
    push(t, 5);
    push(t, 9);
    push(t, 10);
    push(t, 1);
    int_dynarray* result = insertion_sort(t);
    print(result);

    delete(result);
    delete(t);
}


int main(void){
    test_tri();

    return 0;
}

