#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

const uint8_t empty = 0;
const uint8_t occupied = 1;
const uint8_t tombstone = 2;

struct bucket {
    uint8_t status;
    uint32_t element;
};
typedef struct bucket bucket;

struct set {
    int p;
    bucket* a;
    uint64_t nb_empty;
};
typedef struct set set;


/* ———————————————————————————————————————————————————— */
/*  I. Constructeur, destructeur, recherche d'éléments  */
/* ———————————————————————————————————————————————————— */


uint64_t ones(int p) {
    return (1ull << p) - 1ull;
}

uint64_t hash(uint32_t x, int p) {
    return x & ones(p);
}

set* set_new(void) {
    set* new = malloc(sizeof(set));
    new->p = 1;
    new->nb_empty = 2;
    new->a = malloc(2 * sizeof(bucket));
    for (uint64_t i = 0; i < 2; i++) {
        new->a[i].status = empty;
    }
    return new;
}

void set_delete(set* s) {
    free(s->a);
    free(s);
}

/* -> réécrit avec une meilleure implémentation plus loin
bool set_is_member(set* s, uint32_t x) {
    uint64_t h = hash(x, s->p);
    while (s->a[h].status == occupied) {
        if (s->a[h].element == x) return true;
        h = (h + 1) & ones(s->p);
    }
    return false;
}
*/

set *set_example() {
    set *s = malloc(sizeof(set));
    s->p = 2;
    s->a = malloc(4 * sizeof(bucket));
    s->a[0].status = occupied;
    s->a[0].element = 1492;
    s->a[1].status = occupied;
    s->a[1].element = 1939;
    s->a[2].status = empty;
    s->a[3].status = occupied;
    s->a[3].element = 1515;
    s->nb_empty = 1;
    return s;
}


/* —————————————————————————— */
/*  II. Parcours de la table  */
/* —————————————————————————— */


uint32_t set_get(set* s, uint64_t i) {
    assert(s->a[i].status == occupied);
    return s->a[i].element;
}

// On ne cherche pas la dernière case occupée, mais la dernière tout court
uint64_t set_end(set* s) {
    return 1ull << s->p;
}

/* -> réécrit dans la partie avec pierres tombales
uint64_t set_begin(set* s) {
    uint64_t i = 0;
    while (i < set_end(s) && s->a[i].status == empty) {
        i++;
    } // si rien n'est trouvé, renvoie 2^p, ce qui est demandé.
    return i;
}

uint64_t set_next(set* s, uint64_t i) {
    i++;
    while (i < set_end(s) && s->a[i].status == empty) {
        i++;
    } // si rien n'est trouvé, i = 2^p, ce qui est demandé.
    return i;
} */


bool all_even(set* s) {
    for (uint64_t i = set_begin(s); i != set_end(s); i = set_next(s, i)) {
        if (set_get(s, i) % 2 == 1) return false;
    }
    return true;
}


/* ——————————————————————— */
/*  III. Ajout d'éléments  */
/* ——————————————————————— */

/* -> réécrit dans la partie avec pierres tombales
uint64_t set_search(set* s, uint32_t x, bool* found) {
    uint64_t i = hash(x, s->p);
    *found = false;
    while (s->a[i].status == occupied) {
        if (s->a[i].element == x) {
            *found = true;
            break;
        }
        i = (i + 1) & ones(s->p);
    }
    return i;
} */

bool set_is_member(set* s, uint32_t x) {
    bool found;
    set_search(s, x, &found);
    return found;
}

// Attention à mettre 1ull, et à initialiser les cases à empty
void set_resize(set* s, int p) {
    uint64_t size = 1ull << p;
    set* r = malloc(sizeof(set));
    r->p = p;
    r->nb_empty = size;
    r->a = malloc(size * sizeof(bucket));
    for (uint64_t i = 0; i < size; i++) {
        r->a[i].status = empty;
    }

    bool found;
    for (uint64_t i = set_begin(s); i != set_end(s); i = set_next(s, i)) {
        uint32_t x = set_get(s, i);
        uint64_t new_i = set_search(r, x, &found);
        r->a[new_i].element = x;
        r->a[new_i].status = occupied;
        r->nb_empty--;
    }

    free(s->a);
    s->a = r->a;
    s->p = p;
    s->nb_empty = r->nb_empty;
    free(r);
}

void set_add(set* s, uint32_t x) {
    if (s->nb_empty < 2) set_resize(s, s->p + 1);
    bool found = false;
    uint64_t new_i = set_search(s, x, &found);
    if (!found) {
        s->a[new_i].element = x;
        s->a[new_i].status = occupied;
        s->nb_empty--;
    }
}

void test_set(void) {
    set* test = set_new();
    set_add(test, 12);
    set_add(test, 3);
    set_add(test, 5);
    set_add(test, 4);
    set_add(test, 14);
    set_add(test, 9);

    for (uint64_t i = set_begin(test); i != set_end(test); i = set_next(test, i)) {
        printf("%d ", set_get(test, i));
    }
    set_delete(test);
}


/* ———————————————————————————— */
/*  IV. Suppression d'éléments  */
/* ———————————————————————————— */


uint64_t set_begin(set* s) {
    uint64_t i = 0;
    while (i < set_end(s) && s->a[i].status != occupied) {
        i++;
    }
    return i;
}

uint64_t set_next(set* s, uint64_t i) {
    i++;
    while (i < set_end(s) && s->a[i].status != occupied) {
        i++;
    }
    return i;
}

// Pour cette version, si l'élément n'est pas trouvé, on ne veut pas insérer dans une case libre
// mais idéalement dans une pierre tombale -> la première rencontrée pour être opti
uint64_t set_search(set* s, uint32_t x, bool* found) {
    uint64_t i = hash(x, s->p);
    *found = false;
    uint64_t i_tombstone = set_end(s);
    while (s->a[i].status != empty) {
        if (s->a[i].element == x) {
            *found = true;
            break;
        }
        if (s->a[i].status == tombstone && i < i_tombstone) {
            i_tombstone = i;
        }
        i = (i + 1) & ones(s->p);
    }
    if (i >= i_tombstone) return i_tombstone;
    return i;
}

void set_remove(set* s, uint32_t x) {
    bool found;
    uint64_t i = set_search(s, x, &found);
    if (found) s->a[i].status = tombstone;
}


/* —————————————————————————— */
/*  V. Liste des adresses IP  */
/* —————————————————————————— */

uint32_t *read_data(char *filename, int *n) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        return NULL;
    }

    int nb_lines = 0;
    char line[16];
    while (!feof(file)) {
        fscanf(file, "%15s\n", line);
        nb_lines++;
    }
    rewind(file);

    uint32_t *t = malloc(nb_lines * sizeof(uint32_t));
    int a, b, c, d;
    for (int i = 0; i < nb_lines; ++i) {
        int nb_read = fscanf(file, "%d.%d.%d.%d", &a, &b, &c, &d);
        if (nb_read != 4){
            fclose(file);
            free(t);
            return NULL;
        }
        t[i] = (((a * 256u) + b) * 256u + c) * 256u + d;
    }

    fclose(file);

    *n = nb_lines;
    return t;
}

set* read_set(char* filename) {
    int n;
    uint32_t* data = read_data(filename, &n);
    assert(data != NULL);
    set* s = set_new();
    for (int i = 0; i < n; i++) {
        set_add(s, data[i]);
    }
    free(data);
    return s;
}

void set_skip_stats(set* s, double* average, uint64_t* max) {
    
}


int main() {
    test_set();
    return 0;
}

