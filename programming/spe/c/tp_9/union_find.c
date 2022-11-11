#include <stdlib.h>
#include <stdint.h>

typedef int element;

struct partition {
    int nb_sets;
    int nb_elements;
    int *arr;
};

typedef struct partition partition_t;

partition_t *partition_new(int nb_elements) {
    partition_t* res = malloc(sizeof(partition_t));
    res->nb_elements = nb_elements;
    res->nb_sets = nb_elements;
    res->arr = malloc(nb_elements * sizeof(int));
    for (int i = 0; i < nb_elements; i++) {
        res->arr[i] = -1;
    }

    return res;
}

void partition_free(partition_t *p) {
    free(p->nb_sets);
    free(p);
}

element find(partition_t *p, element x) {
    if (p->arr[x] < 0) return x;
    
    int root = find(p, p->arr[x]);
    p->arr[x] = root;
    return root;
}

void merge(partition_t *p, element x, element y) {
    int root_x = find(p, x);
    int root_y = find(p, y);

    // Ne pas oublier le cas où il n'y a rien à faire (au cas où)
    if (root_x == root_y) return;

    int card_x = -1 * p->arr[root_x];
    int card_y = -1 * p->arr[root_y];
    // Attention : ce sont bien des nombres négatifs
    if (card_x < card_y) {
        p->arr[root_x] = root_y;
        p->arr[root_y] -= card_x;
    } else {
        p->arr[root_y] = root_x;
        p->arr[root_x] -= card_y;
    }

    // Et bien sûr, mettre à jour le nombre de sets
    p->nb_sets--;
}


int nb_sets(partition_t *p){
    return p->nb_sets;
}

int nb_elements(partition_t *p){
    return p->nb_elements;
}
