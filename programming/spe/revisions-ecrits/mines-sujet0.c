#include <stdio.h>
#include <stdbool.h>

struct chainon {
    int donnee;
    int hauteur;
    struct chainon **suivants;
};
typedef struct chainon chainon_t;

bool enjmb_contient(chainon_t* t, int v) {
    chainon_t* current = t;
    int height = t->hauteur - 1;

    while (true) {
        current = t->suivants[height];
        while (current->suivants[height]->donnee < v) {
            current = current->suivants[height];
        }
        height--;
        if (height == 0) break;
    }

    return current->donnee == v;
}
