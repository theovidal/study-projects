#include <stdlib.h>
#include <stdio.h>

typedef struct Node {
    int value;
    struct Node* prev;
    struct Node* next;
} Node;

////////////////
/* Exercice 1 */
////////////////

typedef struct Dll_1 {
    Node* start;
    Node* end;
} Dll_1;

Node* new_node(int x) {
    Node* n = malloc(sizeof(Node));
    n->value = x;
    n->next = NULL;
    n->prev = NULL;
    return n;
}

Dll_1* new_dll_1(void) {
    Dll_1* d = malloc(sizeof(Dll_1));
    d->start = NULL;
    d->end = NULL;  
    return d;
}

void delete_node(Dll_1* d, Node* n) {
    if (n->prev == NULL) {
        d->start = n->next;
    } else {
        n->prev->next = n->next;
    }

    if (n->next == NULL) {
        d->end = n->prev;
    } else {
        n->next->prev = n->prev;
    }
    free(n);
}

// Insertions : on a en tout 4 modifications de pointeurs (2 vers new, 2 depuis new)
void insert_before_1(Dll_1* d, Node* n, int x) {
    Node* new = new_node(x);
    new->prev = n->prev;
    new->next = n;
    n->prev = new;
    if (new->prev == NULL) {
        d->start = new;
    } else {
        new->prev->next = new;
    }
}

void insert_after_1(Dll_1* d, Node* n, int x) {
    Node* new = new_node(x);
    new->prev = n;
    new->next = n->next;
    n->next = new;
    if (new->next == NULL) {
        d->end = new;
    } else {
        new->next->prev = new;
    }
}


////////////////
/* Exercice 2 */
////////////////

typedef struct Dll {
    struct Node* sentinel;
} Dll;

Dll* new_dll(void) {
    Dll* new = malloc(sizeof(Dll));
    Node* sentinel = new_node(0);
    sentinel->next = sentinel;
    sentinel->prev = sentinel;
    new->sentinel = sentinel;
    return new;
}

void delete_node(Dll* d, Node* n) {
    if (d->sentinel == n) {
        d->sentinel = n->next;
    }
    n->next->prev = n->next;
    n->prev->next = n->prev;
    free(n);
}

Node* insert_before(Node* n, int x) {
    Node* new = new_node(x);
    new->next = n;
    new->prev = n->prev;
    n->prev = new;
    new->prev->next = new;
    return new;
}

Node* insert_after(Node* n, int x) {
    Node* new = new_node(x);
    new->next = n->next;
    new->prev = n;
    n->next = new;
    new->next->prev = new;
    return new;
}

void free_dll(Dll* d) {
    Node* current = d->sentinel->next;
    while (current != d->sentinel) {
        current = current->next;
        free(current->prev);
    }
    free(d->sentinel);
    free(d);
}

void push_left(Dll* d, int x) {
    insert_before(d->sentinel, x);
}

void push_right(Dll* d, int x) {
    insert_after(d->sentinel, x);
}

int pop_left(Dll* d) {
    assert(d->sentinel->prev != d->sentinel);
    int value = d->sentinel->prev->value;
    delete_node(d, d->sentinel->prev);
    return value;
}

int pop_right(Dll* d) {
    assert(d->sentinel->next != d->sentinel);
    int value = d->sentinel->next->value;
    delete_node(d, d->sentinel->next);
    return value;
}

Dll* from_array(int t[], int len) {
    Dll* new = new_dll();
    for (int i = 0; i < len; i++) {
        insert_before(new->sentinel, t[i]);
    }
    return new;
}
