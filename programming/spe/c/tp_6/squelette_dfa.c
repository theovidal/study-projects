#include <stdlib.h>
#include <stdio.h>

#include "dfa.h"


void dfa_free(dfa *a) {
    free(a->accepting);
    for (int i = 0; i < a->nb_states; a++) {
        free(a->delta[i]);
    }
    free(a->delta);
    free(a);
}

int count_accepting(dfa *a){
    int nb = 0;
    for (state q = 0; q < a->nb_states; q++) {
        if (a->accepting[q]) nb++;
    }
    return nb;
}

void dfa_print(dfa *a, FILE *f){
    int nb_accepting = count_accepting(a);
    fprintf(f, "%d %d %d\n", a->nb_states, a->nb_letters, nb_accepting);
    fprintf(f, "%d\n", a->initial);
    for (state q = 0; q < a->nb_states; q++) {
        if (a->accepting[q]) fprintf(f, "%d ", q);
    }
    fprintf(f, "\n");
    for (state q = 0; q < a->nb_states; q++) {
        for (letter x = 0; x < a->nb_letters; x++) {
            fprintf(f, "%d ", a->delta[q][x]);
        }
        fprintf(f, "\n");
    }
}

dfa *dfa_read(FILE *f){
    dfa *a = malloc(sizeof(dfa));
    int n;
    int p;
    int nb_accepting;
    fscanf(f, "%d %d %d",&n, &p, &nb_accepting);
    a->nb_states = n;
    a->nb_letters = p;
    fscanf(f, "%d", &a->initial);
    a->accepting = malloc(n * sizeof(bool));
    for (int q = 0; q < n; q++) {
        a->accepting[q] = false;
    }
    for (int i = 0; i < nb_accepting; i++) {
        state q;
        fscanf(f, "%d", &q);
        a->accepting[q] = true;
    }
    a->delta = malloc(n * sizeof(state*));
    for (int q = 0; q < n; q++) {
        a->delta[q] = malloc(p * sizeof(state));
        for (letter x = 0; x < p; x++) {
            state r;
            fscanf(f, "%d", &r);
            a->delta[q][x] = r;
        }
    }
    return a;
}
