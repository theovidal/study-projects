#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include "dfa.h"

int DEBUG = 0;

typedef int class;

struct partitioned_dfa {
    dfa *dfa;
    state *ordered_states;
    class *classes;
    int nb_classes;
};

typedef struct partitioned_dfa partitioned_dfa;

void print_int_array(int arr[], int n){
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}


partitioned_dfa *initialize_partition(dfa *a){
    partitioned_dfa *b = malloc(sizeof(partitioned_dfa));
    int n = a->nb_states;

    b->dfa = a;
    b->nb_classes = 2;
    b->ordered_states = malloc(n * sizeof(state));
    b->classes = malloc(n * sizeof(class));

    int nb_accepting = 0;
    int nb_non_accepting = 0;
    for (state q = 0; q < n; q++) {
        if (a->accepting[q]) {
            b->ordered_states[nb_accepting] = q;
            b->classes[q] = 0;
            nb_accepting++;
        } else {
            b->ordered_states[n - 1 - nb_non_accepting] = q;
            b->classes[q] = 1;
            nb_non_accepting++;
        }
    }

    return b;
}




void zero_out(int t[], int n){
    for (int i = 0; i < n; i++) {
        t[i] = 0;
    }
}

class destination_class(partitioned_dfa *a, state q, letter x){
    state dest_state = a->dfa->delta[q][x];
    return a->classes[dest_state];
}

bool discriminate(partitioned_dfa *a, state q, state r){
    if (a->classes[q] != a->classes[r]) return true;
    for (letter x = 0; x < a->dfa->nb_letters; x++){
        if (destination_class(a, q, x) != destination_class(a, r, x)) {
            return true;
        }
    }
    return false;
}


class *refine(partitioned_dfa *a){
    int n = a->dfa->nb_states;
    class *new_classes = malloc(n * sizeof(class));
    for (state q = 0; q < n; q++) {
        new_classes[q] = -1;
    }
    class current_class = 0;
    for (state q = 0; q < n; q++) {
        if (new_classes[q] >= 0) continue;
        for (state r = 0; r < n; r++) {
            if (!discriminate(a, q, r)) new_classes[r] = current_class;
        }
        current_class++;
    }
    return new_classes;
}


int *histogram(partitioned_dfa *a, letter x){
    int *h = malloc(a->nb_classes * sizeof(int));
    zero_out(h, a->nb_classes);
    int n = a->dfa->nb_states;
    for (int i = 0; i < n; i++) {
        state q = a->ordered_states[i];
        class c = destination_class(a, q, x);
        h[c]++;
    }
    return h;
}

void inplace_prefix_sum(int h[], int nb_values){
    int sum = 0;
    for (int i = 0; i < nb_values; i++) {
        int tmp = h[i];
        h[i] = sum;
        sum += tmp;
    }
}

void sort_by_transition(partitioned_dfa *a, letter x){
    int n = a->dfa->nb_states;

    int *new_ordered_states = malloc(n * sizeof(state));
    int *hist = histogram(a, x);
    inplace_prefix_sum(hist, a->nb_classes);

    for (int i = 0; i < n; i++) {
        state q = a->ordered_states[i];
        class c = destination_class(a, q, x);
        if (DEBUG) {
            printf("dest_class : %d %d -> %d\n", q, x, c);
        }
        new_ordered_states[hist[c]] = q;
        hist[c]++;
    }

    free(hist);
    free(a->ordered_states);
    a->ordered_states = new_ordered_states;
}

bool step(partitioned_dfa *a){
    for (letter x = 0; x < a->dfa->nb_letters; x++){
        sort_by_transition(a, x);
    }
    int n = a->dfa->nb_states;
    class current_class = 0;
    int *new_classes = malloc(n * sizeof(class));
    new_classes[a->ordered_states[0]] = 0;
    for (int i = 1; i < n; i++){
        state q = a->ordered_states[i];
        if (discriminate(a, q, a->ordered_states[i - 1])) {
            current_class++;
        }
        new_classes[q] = current_class;
    }
    free(a->classes);
    a->classes = new_classes;
    bool res = (a->nb_classes != current_class + 1);
    a->nb_classes = current_class + 1;

    if (DEBUG) {
        printf("step\n");
        printf("nb_classes : %d\n", a->nb_classes);
        printf("classes = ");
        print_int_array(a->classes, a->dfa->nb_states);
    }
    return res;
}

dfa *to_dfa(partitioned_dfa *a){
    dfa *b = malloc(sizeof(dfa));
    b->nb_states = a->nb_classes;
    b->nb_letters = a->dfa->nb_letters;

    b->accepting = malloc(b->nb_states * sizeof(bool));
    for (state q = 0; q < a->dfa->nb_states; q++) {
        int c = a->classes[q];
        b->accepting[c] = a->dfa->accepting[q];
    }

    b->delta = malloc(b->nb_states * sizeof(state*));
    for (class c = 0; c < b->nb_states; c++) {
        b->delta[c] = malloc(b->nb_letters * sizeof(state));
    }
    for (state q = 0; q < a->dfa->nb_states; q++) {
        class c = a->classes[q];
        for (letter x = 0; x < b->nb_letters; x++) {
            b->delta[c][x] = destination_class(a, q, x);
        }
    }
    b->initial = a->classes[a->dfa->initial];

    return b;
}


dfa *minimize(dfa *a){
    partitioned_dfa *b = initialize_partition(a);
    while (step(b)) {}
    dfa *a_minimal = to_dfa(b);
    free(b->classes);
    free(b->ordered_states);
    free(b);
    return a_minimal;
}

int main(int argc, char *argv[]){
    DEBUG = 0;

    FILE *in = stdin;
    FILE *out = stdout;
    // dfa *a = random_dfa(10, 2, 0.5);
    if (argc > 1) in = fopen(argv[1], "r");
    dfa *a = dfa_read(in);
    fclose(in);
    if (argc > 2) out = fopen(argv[2], "w");
    /* dfa_print(a, out); */
    dfa *a_min = minimize(a);
    dfa_print(a_min, out);
    fclose(out);
    dfa_free(a);
    dfa_free(a_min);
}
