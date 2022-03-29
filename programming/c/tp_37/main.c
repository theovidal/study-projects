#include <stdio.h>
#include <stdlib.h>
#include "stack.h"
#include "graph.h"

int* read_data(int* nb_vertex, int* nb_edges) {
    scanf("%d %d\n", nb_vertex, nb_edges);
    int* data = malloc(2 * *nb_edges * sizeof(int));
    for (int i = 0; i < *nb_edges; i++) {
        scanf("%d %d\n", &data[2 * i], &data[2 * i + 1]);
    }
    return data;
}

stack* euler(graph g, int nb_edges) {
    stack* actuel = stack_new(nb_edges + 1);
    stack* eul = stack_new(nb_edges + 1);

    stack_push(actuel, 0);
    while (!stack_is_empty(actuel)) {
        int last = stack_peek(actuel);

        if (has_available_edge(g, last)) {
            edge next = get_edge(g, last);
            delete_edge(g, next);
            stack_push(actuel, next.to);
        }
        else {
            stack_push(eul, last);
            stack_pop(actuel);
        }
    }

    stack_free(actuel);
    return eul;
}

void print_path(int x) {
    printf("%d – ", x);
}

int main(void) {
    int nb_vertex = 0;
    int nb_edges = 0;
    int* data = read_data(&nb_vertex, &nb_edges);

    graph g = build_graph(data, nb_vertex, nb_edges);
    stack* path = euler(g, nb_edges);

    while (!stack_is_empty(path)) {
        printf("%d – ", stack_pop(path));
    }
    graph_free(g);
    stack_free(path);
}
