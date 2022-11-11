#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#include "graph.h"

graph_t* empty_graph() {
    return malloc(sizeof(graph_t));
}

void graph_free(graph_t *g){
    free(g->degrees);
    for (int i = 0; i < g->n; i++) {
        free(g->adj[i]);
    }
    free(g->adj);
    free(g);
}

graph_t *read_graph(FILE *fp){
    int n;
    fscanf(fp, "%d", &n);
    int *degrees = malloc(n * sizeof(int));
    edge **adj = malloc(n * sizeof(edge*));
    for (int i = 0; i < n; i++){
        fscanf(fp, "%d", &degrees[i]);
        printf("%d : %d\n", i, degrees[i]);
        adj[i] = malloc(degrees[i] * sizeof(edge));
        for (int j = 0; j < degrees[i]; j++) {
            edge e;
            e.x = i;
            fscanf(fp, " (%d, %f)", &e.y, &e.rho);
            adj[i][j] = e;
        }
    }
    graph_t *g = malloc(sizeof(graph_t));
    g->degrees = degrees;
    g->n = n;
    g->adj = adj;
    return g;
}

void print_graph(graph_t *g, FILE *fp){
    fprintf(fp, "%d\n", g->n);
    for (int i = 0; i < g->n; i++) {
        fprintf(fp, "%d ", g->degrees[i]);
        for (int j = 0; j < g->degrees[i]; j++) {
            edge e = g->adj[i][j];
            fprintf(fp, "(%d, %.3f) ", e.y, e.rho);
        }
        fprintf(fp, "\n");
    }
}

// Graphe non orienté : directement renvoyer (nombre total)/2
int number_of_edges(graph_t *g) {
    int nb = 0;
    for (int i = 0; i < g->n; i++) {
        nb += g->degrees[i];
    }
    return nb/2;
}

// On choisit arbitrairement l'une ou l'autre arête :
// ici, le critère sera de prendre une arête si x < y
edge *get_edges(graph_t *g, int *nb_edges) {
    *nb_edges = number_of_edges(g);
    edge* t = malloc(*nb_edges * sizeof(edge));
    int current = 0;
    for (int i = 0; i < g->n; g++) {
        for (int j = 0; j < g->degrees[i]; g++) {
            edge e = g->adj[i][j];
            if (e.x < e.y) {
                t[current] = e;
                current++;
            }
        }
    }
}

int compare_edges(const void* pa, const void* pb) {
    edge* a = (edge*)pa;
    edge* b = (edge*)pb;
    return a->rho - b->rho;
}

void sort_edges(edge *edges, int p) {
    qsort(edges, p, sizeof(edge), compare_edges);
}

void print_edge_array(edge *edges, int len) {
    for (int i = 0; i < len; i++) {
        printf("%d <-- %f --> %d\n", edges[i].x, edges[i].rho, edges[i].y);
    }
}

