#ifndef __GRAPH_H
#define __GRAPH_H

#include <stdbool.h>

// All fields should be considered private.
struct graph {
    int nb_vertex;
    int nb_edges;
    int *edges;
    int *offsets;
    int *adjacency;
    int *nb_remaining_edges;
};

// from and to are both vertex numbers. The index field should
// be considered private.
struct edge {
    int from;
    int to;
    int index; 
};

typedef struct edge edge;

typedef struct graph graph;


// Is there an (unused) edge from vertex x ?
bool has_available_edge(graph g, int x);


// Get an unused edge from vertex x. The "from" field value will
// be x, the "to" field value will indicate the other endpoint.
//
// Precondition : there exists such an edge.
edge get_edge(graph g, int x);


// Remove an edge from the graph.
// Precondition : the edge must exist and be unused.
void delete_edge(graph g, edge e);

// Build a graph from an array defining the edges.
// Preconditions :
//  - edge_data is of length 2 * nb_edges
//  - every element of edge_data is between 0 and nb_vertex - 1, inclusive
//  - for each i s.t. 0 <= i < nb_edges, the endpoints of the i-th edge
//    are edge_data[2 * i] and edge_data[2 * i + 1].
//  - the order of edges and of endpoints within one edge are unspecified
//
// Example :
// 1 - 2 - 3    {1, 2, 2, 3, 1, 4, 4, 2, 3, 5}
//  \ /    |
//   4     5
//
//
// IMPORTANT : the graph takes ownership of the edge_data array, which
// means this array will get freed when graph_free is called (and must
// not be freed separately).
graph build_graph(int *edge_data, int nb_vertex, int nb_edges);


// Free all resources used by the graph.
void graph_free(graph g);

#endif

