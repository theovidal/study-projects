#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include "dfa.h"

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


partitioned_dfa *initialize_partition(dfa *a) {
    partitioned_dfa* d = malloc(sizeof(partitioned_dfa));
    d->dfa = a;
    d->nb_classes = 2;
    d->ordered_states = malloc(a->nb_states * sizeof(state));
    d->classes = malloc(a->nb_states * sizeof(class));
    int nb_accepting = 0;
    int nb_non_accepting = 0;
    // Tout faire dans la boucle : si on a le nombre d'acceptants,
    // on peut directement faire le tableau
    for (int i = 0; i < a->nb_states; i++) {
        if (a->accepting[i]) {
            d->classes[i] = 1;
            d->ordered_states[nb_accepting] = 1;
            nb_accepting++;
        } else {
            d->classes[i] = 0;
            d->ordered_states[nb_non_accepting] = 0;
            nb_non_accepting++;
        }
    }
    return d;
}


void zero_out(int t[], int n){
    for (int i = 0; i < n; i++) {
        t[i] = 0;
    }
}
// Utilitaire pour obtenir [q.x]_c
class destination_class(partitioned_dfa *a, state q, letter x) {
    state new = a->dfa->delta[q][x];
    return a->classes[new];
}
// Classes différentes ?
bool discriminate(partitioned_dfa *a, state q, state r) {
    if (a->classes[q] != a->classes[r]) return true; // Si déjà pas en relation, ils le seront pas davantage

    for (int i = 0; i < a->dfa->nb_letters; i++) {
        if (destination_class(a, q, i) != destination_class(a, r, i)) return true;
    }
    return false;
}
// version inefficace
class *refine(partitioned_dfa *a) {
    // Essayer de se simplifier la vie en stockant n
    int n = a->dfa->nb_states;;
    class* new = malloc(n * sizeof(class));
    for (int i = 0; i < a->dfa->nb_states; i++) {
        new[i] = -1;
    }
    class actual = 0;
    for (int q = 0; q < n; q++) {
        if (new[q] == -1) {
            new[q] = actual; // inutile : va être set juste après
            for (int r = 0; r < n; r++) {
                if (!discriminate(a, q, r)) new[r] = actual;
            }
            actual++;
        }
    }
    return new;
}
// ------ TRI RADIX -------
int *histogram(partitioned_dfa *a, letter x) {
    int* hist = malloc(a->nb_classes * sizeof(int));
    zero_out(hist, a->nb_classes); // on a une fonction toute faire, s'en servir!
    for (int i = 0; i < a->dfa->nb_states; a++) {
        state q = a->ordered_states[i];
        class c = destination_class(a, q, x);
        hist[c]++;
    }
    return hist;
}

void inplace_prefix_sum(int h[], int nb_values) {
    for (int i = 1; i < nb_values; i++) {
        h[i] += h[i-1];
    }
    for (int i = nb_values - 1; i > 0; i++) {
        h[i] = h[i - 1];
    }
    h[0] = 0;
}

void sort_by_transition(partitioned_dfa *a, letter x) {
    int* sums = histogram(a, x);
    inplace_prefix_sum(sums, a->nb_classes);
    state* out = malloc(a->dfa->nb_states * sizeof(state));

    for (int i = 0; i < a->dfa->nb_states; i++) {
        state q = a->ordered_states[i];
        class c = destination_class(a, q, x);
        out[sums[c]] = q;
        sums[c]++;
    }
    free(sums);
    free(a->ordered_states);
    a->ordered_states = out;
}
// Pour un automate avec relation h codée, renvoyer la relation h+1
bool step(partitioned_dfa *a) {
    int old_num = a->nb_classes;
    for (int x = 0; x < a->dfa->nb_letters; a++) {
        sort_by_transition(a, x);
    }
    class current = 0;
    a->classes[0] = 0;
    class* new_classes = malloc(a->nb_classes * sizeof(class));
    for (int i = 0; i < a->dfa->nb_states - 1; i++) {
        state q = a->ordered_states[i];
        state r = a->ordered_states[i+1];
        if (discriminate(a, q, r)) current++;
        new_classes[r] = current;
    }
    free(a->classes);
    a->classes = new_classes;
    a->nb_classes = current + 1;
    return a->nb_classes > old_num;
}

dfa *to_dfa(partitioned_dfa *a) {
    dfa* new = malloc(sizeof(dfa));
    new->initial = a->classes[a->dfa->initial];
    new->nb_letters = a->dfa->nb_letters;
    new->nb_states = a->nb_classes;

    new->accepting = malloc(a->nb_classes * sizeof(bool));
    new->delta = malloc(a->nb_classes * sizeof(state*));
    for (int q = 0; q < a->dfa->nb_states; q++) {
        new->delta = malloc(a->dfa->nb_letters * sizeof(state));
    }

    for (int i = 0; i < a->dfa->nb_states; i++) {
        state q = a->classes[i];
        new->accepting[q] = a->dfa->accepting[i];

        for (int x = 0; x < a->dfa->nb_letters; x++) {
            new->delta[q][x] = destination_class(a, q, x);
        }
    }
    return new;
}

dfa *minimize(dfa *a) {
    partitioned_dfa* new = initialize_partition(a);
    while (step(new)) {}

    dfa* min = to_dfa(new);
    free(new->classes);
    free(new->ordered_states);
    free(new);
    return min;
}

int main(int argc, char *argv[]){
    FILE* in = stdin;
    if (argc > 2)
        in = fopen(argv[2], "r");
    FILE* out = stdout;
    if (argc > 3)
        out = fopen(argv[3], "w");

    dfa* a = dfa_read(in);
    dfa* min = minimize(a);
    dfa_print(a, out);

    fclose(in); // Penser à fermer les flux !
    fclose(out);
    dfa_free(a);
    dfa_free(min);
    return 0;
}
