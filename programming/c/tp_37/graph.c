#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>


#include "graph.h"


bool has_available_edge(graph g, int x){
    return g.nb_remaining_edges[x] > 0;
}

edge get_edge(graph g, int x){
    assert(has_available_edge(g, x));
    int index = g.adjacency[g.offsets[x]];
    while (g.edges[index] == -1){
        g.offsets[x]++;
        index = g.adjacency[g.offsets[x]];
    }
    edge e;
    e.from = x;
    e.to = g.edges[index];
    e.index = index;
    return e;
}

void delete_edge(graph g, edge e){
    int x = e.from;
    int y = e.to;
    int i = e.index - (e.index % 2);

    g.edges[i] = -1;
    g.edges[i + 1] = -1;

    g.nb_remaining_edges[x]--;
    g.nb_remaining_edges[y]--;
}

int *histogram(int *arr, int len, int bound){
    int *hist = malloc(bound * sizeof(int));

    for (int i = 0; i < bound; i++){
        hist[i] = 0;
    }

    for (int i = 0; i < len; i++){
        hist[arr[i]]++;
    }
    return hist;
}

int *prefix_sum(int *arr, int len){
    int *prefix = malloc(len * sizeof(int));
    int s = 0;
    for (int i = 0; i < len; i++){
        prefix[i] = s;
        s += arr[i];
    }
    return prefix;
}


graph build_graph(int *edge_data, int nb_vertex, int nb_edges){
    int *hist = histogram(edge_data, 2 * nb_edges, nb_vertex);
    int *offsets = prefix_sum(hist, nb_vertex);
    int *adjacency = malloc(2 * nb_edges * sizeof(int));
    int *nb_remaining_edges = malloc(nb_vertex * sizeof(int));

    for (int i = 0; i < nb_vertex; i++){
        nb_remaining_edges[i] = 0;
    }

    for (int i = 0; i < 2 * nb_edges; i = i + 2) {
        int x = edge_data[i];
        int y = edge_data[i + 1];

        adjacency[offsets[x]] = i + 1;
        offsets[x]++;
        nb_remaining_edges[x]++;

        adjacency[offsets[y]] = i;
        offsets[y]++;
        nb_remaining_edges[y]++;
    }
    free(offsets);
    offsets = prefix_sum(hist, nb_vertex);
    free(hist);

    graph g;
    g.nb_vertex = nb_vertex;
    g.nb_edges = nb_edges;
    g.edges = edge_data;
    g.offsets = offsets;
    g.adjacency = adjacency;
    g.nb_remaining_edges = nb_remaining_edges;

    return g;
}

void graph_free(graph g){
    free(g.edges);
    free(g.offsets);
    free(g.adjacency);
    free(g.nb_remaining_edges);
}

