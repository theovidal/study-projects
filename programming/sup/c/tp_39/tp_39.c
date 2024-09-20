#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>


void matrix_print(bool** m, int n, int p){
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < p; j++) {
            printf("%d ", m[i][j]);
        }
        printf("\n");
    }
}

void array_print(bool* a, int n) {
    for (int i = 0; i < n; i++) {
        printf("%d ", a[i]);
    }
    printf("\n");
}

bool** matrix_new(int n, int p) {
    bool** m = malloc(n * sizeof(bool*));
    for (int i = 0; i < n; i++) {
        m[i] = malloc(p * sizeof(bool));
    }

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < p; j++) {
            m[i][j] = false;
        }
    }

    return m;
}

void matrix_free(bool** m, int n) {
    for (int i = 0; i < n; i++) {
        free(m[i]);
    }
    free(m);
}

bool** identity(int n) {
    bool** m = matrix_new(n, n);
    for (int i = 0; i < n; i++) {
        m[i][i] = true;
    }
    return m;
}

// Reads a graph from standard input and returns
// its adjacency matrix. Data format is :
//   - first line : two integers n and p, separated by a space.
//     n is the number of vertices, p the number of edges.
//     Vertices are numbered 0..n-1.
//   - next p lines : two integers x and y per line, separated by a space.
//     Corresponds to an edge from vertex x to vertex y.
//
// Output paramter n is set to the number of vertices by the call
// to read_data.
bool** read_data(int* n){
    int nb_edges;
    scanf("%d %d", n, &nb_edges);
    bool **a = matrix_new(*n, *n);
    for (int k = 0; k < nb_edges; k++) {
        int i, j;
        scanf("%d %d", &i, &j);
        a[i][j] = true;
    }
    return a;
}

bool** product(bool** a, bool** b, int n, int p, int q) {
    bool** result = matrix_new(n, q);
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < q; j++) {
            for (int k = 0; k < p; k++) {
                result[i][j] |= a[i][k] && b[k][j];
            }
        }
    }
    return result;
}

// Attention de bien libérer les matrices intermédiaires avec matrix_free !
bool** matrix_pow(bool** a, int n, int p) {
    if (p == 0) return identity(n);

    bool** square = product(a, a, n, n, n);

    if (p % 2 == 0) {
        bool** res = matrix_pow(square, n, p / 2);
        matrix_free(square, n);
        return res;
    }
    else {
        bool** with_power = matrix_pow(square, n, (p - 1) / 2);
        bool** res = product(a, with_power, n, n, n);
        matrix_free(square, n);
        matrix_free(with_power, n);
        return res;
    }
}

bool** closure(bool** a, int n) {
    return matrix_pow(a, n, n - 1);
}

void explore(bool** a, bool* known, int n, int x) {
    if (known[x] == false) {
        known[x] = true;
        for (int i = 0; i < n; i++) {
            if (a[x][i]) explore(a, known, n, i);
        }
    }
}

bool* accessible(bool** a, int n, int i) {
    bool* known = malloc(n * sizeof(bool));
    for (int i = 0; i < n; i++) {
        known[i] = false;
    }
    
    explore(a, known, n, i);
    return known;
}

bool** closure_dfs(bool** a, int n) {
    bool** res = malloc(n * sizeof(bool*));
    for (int i = 0; i < n; i++) {
        res[i] = accessible(a, n, i);
    }
    return res;
}

bool is_axiom(bool** b, int n, int i) {
    bool** clos = closure_dfs(b, n);
    for (int j = 0; j < n; j++) {
        if (!clos[i][j] || !clos[j][i]) return false;
    }
    return true;
}

/*
bool* axiom_system(bool** b, int n);
*/

void print_system(bool* system, int n){
    for (int i = 0; i < n; i++) {
        if (system[i]) printf("%d ", i);
    }
    printf("\n");
}

int main(void){
    int n = 4;
    bool** m = matrix_new(n, n);
    m[0][0] = true;
    m[1][1] = true;
    m[2][2] = true;
    m[3][3] = true;
    m[0][2] = true;
    m[2][3] = true;
    m[3][0] = true;
    m[3][1] = true;

    bool** c = closure_dfs(m, n);
    matrix_print(c, n, n);
    matrix_free(c, n);
    printf("\n");

    matrix_free(m, n);
    return 0;
}