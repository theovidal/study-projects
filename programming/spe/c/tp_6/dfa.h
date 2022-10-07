#ifndef DFA_H
#define DFA_H

#include <stdio.h>
#include <stdbool.h>

typedef int state;

typedef int letter;

struct dfa {
    int nb_states;
    int nb_letters;
    int initial;
    state **delta;
    bool *accepting;
};

typedef struct dfa dfa;

void dfa_free(dfa *a);

void dfa_print(dfa *a, FILE *f);

dfa *dfa_read(FILE *f);

#endif
