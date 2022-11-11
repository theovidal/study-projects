#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#include "graph.h"
#include "union_find.h"

edge* kruskal(graph_t* g, int* nb_chosen) {
    edge* t = malloc(g->n * sizeof(vertex));
    *nb_chosen = 0;
    partition_t* p = partition_new(g->n);
    int nb_edges;
    edge* all = get_edges(g, &nb_edges);
    sort_edges(all, nb_edges);

    for (int i = 0; i < nb_edges; i++) {
        if (nb_sets(p) == 1) break;
        edge e = all[i];
        if (find(p, e.x) != find(p, e.y)) {
            merge(p, e.x, e.y);
            t[*nb_chosen] = e;
            *nb_chosen++;
        }
    }
    free(all);
    return t;
}


int main(void){
    graph_t* g = read_graph(stdin);
    int nb_chosen;
    edge* t = kruskal(g, &nb_chosen);
    float weight = 0;
    for (int i = 0; i < nb_chosen; i++) {
        weight += t[i].rho;
    }
    printf("Total weight %f", weight);
    print_edge_array(t, nb_chosen);

    free(t);
    graph_free(g);
    return 0;
}
