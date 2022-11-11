#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

#include "graph.h"

void explore(graph_t* g, int i, int* comps, int num) {
    if (comps[i] == -1) {
        comps[i] = num;
        for (int j = 0; j < g->degrees[i]; j++) {
            explore(g, j, comps, num);
        }
    }
}

int* get_components(graph_t* g, int* nb_components) {
    *nb_components = 0;
    int* comps = malloc(g->n * sizeof(int));
    for (int i = 0; i < g->n; i++) {
        comps[i] = -1;
    }

    for (int i = 0; i < g->n; i++) {
        if (comps[i] == -1) {
            explore(g, i, comps, *nb_components);
            *nb_components++;
        }
    }
    return comps;
}

graph_t* without_edges(graph_t* t) {
    graph_t *g = empty_graph();
    g->n = t->n;
    g->degrees = malloc(t->n * sizeof(int));
    g->adj = malloc(t->n * sizeof(edge*));
    for (int i = 0; i < g->n; i++) {
        g->degrees[i] = 0;
        g->adj[i] = malloc(g->degrees[i] * sizeof(edge));
    }
    return g;
}

edge* get_minimal_edges(graph_t* g, int* components, int nb_components) {
    edge* minimals = malloc(nb_components * sizeof(edge));
    for (int i = 0; i < nb_components; i++) {
        edge e = {.x = -1, .y = -1, .rho = INFINITY};
        minimals[i] = e;
    }

    // À retravailler : il faut plutôt traiter toutes! les edges, ne pas retirer les doublons
    int p = number_of_edges(g);
    edge* all = get_edges(g, p);
    for (int i = 0; i < p; i++) {
        edge e = all[i];
        int c = components[e.x];
        if (c != components[e.y] && e.rho < minimals[c].rho) {
            minimals[c] = e;
        }
    }

    free(all);
    return minimals;
}

// Ne pas oublier d'ajouter l'arête inverse !
bool add_edges(graph_t* g, graph_t* t) {
    int nb_components;

    int* components = get_components(t, &nb_components);
    if (nb_components < 2) {
        free(components);
        return true;
    }

    edge* mins = get_minimal_edges(g, components, nb_components);
    for (int i = 0; i < nb_components; i++) {
        edge e = mins[i];
        int j = components[e.y];
        if (j < i && components[mins[j].y] == components[e.x]) continue;
        t->adj[e.x][e.y] = e;
        edge reverse = {.x = e.y, .y = e.x, .rho = e.rho};
        t->adj[e.y][e.x] = reverse;
        t->degrees[e.x]++;
        t->degrees[e.y]++;
    }

    free(components);
    free(mins);
    return false;
}

graph_t* boruvska(graph_t* g) {
    graph_t* t = without_edges(g);
    while (!add_edges(g, t)) {};
    return t;
}

int main(void){
    return 0;
}
