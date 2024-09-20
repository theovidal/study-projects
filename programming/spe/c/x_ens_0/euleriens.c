#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#define N 100

typedef struct Edge {
    int src, dst;
    struct Edge *next, *prev;
} edge;

// Relie deux arcs
void connect(edge* x, edge* y) {
    assert(x->dst == y->src);
    x->next = y;
    y->prev = x;
}

// Joint les deux cycles (même source)
void join(edge* c1, edge* c2) {
    assert(c1->src == c2->src);
    edge* p = c1->prev;
    edge* q = c2->prev;
    connect(q, c1);
    connect(p, c2);
}

edge *graph[N][N];
// et sa matrice d’adjacence
bool has_edges(int v) {
    // indique s’il y a au moins un arc sortant de v
    for (int j = 0; j < N; j++)
        if (graph[v][j] != NULL)
            return true;
    return false;
}
edge *any_edge_from(int v) {
// renvoie un arc sortant de v
// l’arc est supprimé du graphe (et l’arc inverse également)
    for (int j = 0; j < N; j++) {
        if (graph[v][j] == NULL) continue;
        edge *e = graph[v][j];
        graph[v][j] = NULL;
        graph[j][v] = NULL;
        return e;
    }
    return NULL;
}

bool is_eulerian() {
    for (int i = 0; i < N; i++) {
        int count = 0;
        for (int j = 0; j < N; j++) {
            if (graph[i][j] != NULL) count++;
        }
        if ((count & 1) == 1) return false;
    }
    return true;
}

edge *round_trip(int start) {
    edge* s = any_edge_from(start);
    edge* current = s;
    while (current->dst != start) {
        edge* next = any_edge_from(current->dst);
        connect(current, next);
        current = next;
    }
    connect(current, s);
    return s;
}

edge *find_vertex_with_edges(edge *c) {
    edge* current = c;
    while (current->next != c && !has_edges(c->src)) {
        current = current->next;
    }
    int v = c->src;
    for (int j = 0; j < N; j++) {
        if (graph[v][j] == NULL) continue;
        edge *e = graph[v][j];
        graph[v][j] = NULL;
        graph[j][v] = NULL;
        return e;
    }
}

edge *eulerian_cycle(int start) {
    edge* c = round_trip(start);
    edge* f = find_vertex_with_edges(c);
    while (f != NULL) {
        edge* s = round_trip(f->src);
        join(c, s);
        f = find_vertex_with_edges(c);
    }
    return c;
}
