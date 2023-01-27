#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>


struct dense {
    int nb_rows;
    int nb_columns;
    bool **data;
};

typedef struct dense Dense;

struct partial {
    bool *selected_rows;
    bool *remaining_rows;
    bool *remaining_columns;
};

typedef struct partial Partial;


void dense_free(Dense *inst){
    for (int r = 0; r < inst->nb_rows; r++) {
        free(inst->data[r]);
    }
    free(inst->data);
    free(inst);
}

bool *all_false(int n){
    bool *t = malloc(n * sizeof(bool));
    for (int i = 0; i < n; i++) t[i] = false;
    return t;
}

bool *all_true(int n){
    bool *t = malloc(n * sizeof(bool));
    for (int i = 0; i < n; i++) t[i] = true;
    return t;
}

void partial_free(Partial *partial){
    free(partial->selected_rows);
    free(partial->remaining_rows);
    free(partial->remaining_columns);
    free(partial);
}


bool *copy(bool *arr, int len){
    bool *new_arr = malloc(len * sizeof(bool));
    for (int i = 0; i < len; i++) new_arr[i] = arr[i];
    return new_arr;
}

Partial *partial_copy(Partial *partial, int n, int p){
    Partial *new_partial = malloc(sizeof(Partial));
    new_partial->selected_rows = copy(partial->selected_rows, n);
    new_partial->remaining_rows = copy(partial->remaining_rows, n);
    new_partial->remaining_columns = copy(partial->remaining_columns, p);
    return new_partial;
}

Partial *partial_new(Dense *inst){
    Partial *partial = malloc(sizeof(Partial));
    partial->remaining_rows = all_true(inst->nb_rows);
    partial->selected_rows = all_false(inst->nb_rows);
    partial->remaining_columns = all_true(inst->nb_columns);
    return partial;
}

// returns true iff i is an available row, j an
// uncovered column and i covers j
bool get(Dense *inst, Partial *partial, int i, int j){
    return
        partial->remaining_rows[i]
        && partial->remaining_columns[j]
        && inst->data[i][j];
}


// Exercice 4

bool **read_matrix(int *n, int *p) {
    scanf("%d %d", n, p);
    bool** mat = malloc(*n * sizeof(bool*));
    for (int i = 0; i < *n; i++) {
        mat[i] = malloc(*p * sizeof(bool));
        for (int j = 0; j < *p; j++) {
            int temp;
            scanf("%d", &temp);
            mat[i][j] = temp;
        }
    }
    return mat;
}

Dense *read_instance(void) {
    Dense* inst = malloc(sizeof(Dense));
    inst->nb_rows = 0;
    inst->nb_columns = 0;
    inst->data = read_matrix(&inst->nb_rows, &inst->nb_columns);
    return inst;
}

void print_partial_instance(Dense *inst, Partial *partial) {
    for (int i = 0; i < inst->nb_rows; i++) {
        for (int j = 0; j < inst->nb_columns; j++) {
            if (partial->remaining_columns[j] && partial->remaining_rows[i]) {
                printf("%d", inst->data[i][j]);
            }
        }
    }
}

void print_partial_solution(Dense *inst, Partial *partial) {
    printf("Selected lines: ");
    for (int i = 0; i < inst->nb_rows; i++) {
        if (partial->selected_rows[i]) printf("%d ", i);
    }
    printf("\n");
}

void print_pentomino_solution(Dense *inst, Partial* partial, int n, int p) {
    char** plate = malloc(n * sizeof(char*));
    for (int i = 0; i < n; i++) {
        plate[i] = malloc(p * sizeof(char));
        for (int j = 0; j < p; j++) {
            plate[i][j] = 'X';
        }
    }

    char current = 65;
    for (int r = 0; r < inst->nb_rows; r++) {
        if (partial->selected_rows[r]) {
            for (int j = 12; j < inst->nb_columns; j++) {
                if (inst->data[r][j]) {
                    int row = (j - 12)%p;
                    int column = (j - 12)/p;
                    plate[row][column] = current;
                }
            }
            current++;
        }
    }

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < p; j++) {
            printf("%c", plate[i][j]);
        }
        printf("\n");
    }

    for (int i = 0; i < n; i++) {
        free(plate[i]);
    }
    free(plate);
}


// Exercice 5

void cover_column(Dense *inst, Partial *partial, int r, int c) {
    partial->remaining_columns[c] = false;
    for (int i = 0; i < inst->nb_rows; i++) {
        if (i != r && inst->data[i][c]) partial->remaining_rows[i] = false;
    }
}

void select_row(Dense *inst, Partial *partial, int r) {
    partial->remaining_rows[r] = false;
    partial->selected_rows[r] = true;
    for (int j = 0; j < inst->nb_columns; j++) {
        if (inst->data[r][j]) cover_column(inst, partial, r, j);
    }
}


// Exercice 6

int choose_first_column(Dense *inst, Partial *partial) {
    int column = -1;
    for (int j = 0; j < inst->nb_columns; j++) {
        if (partial->remaining_columns[j]) {
            column = j;
            break;
        }
    }
    return column;
}

int count(Dense *inst, Partial *partial) {
    int nb_columns = 0;
    for (int j = 0; j < inst->nb_columns; j++) {
        if (partial->remaining_columns[j]) {
            nb_columns++;
            break;
        }
    }
    if (nb_columns == 0) return 1;

    int nb_rows = 0;
    for (int i = 0; i < inst->nb_rows; i++) {
        if (partial->remaining_rows[i]) {
            nb_rows++;
            break;
        }
    }
    if (nb_rows == 0) return 0;

    int nb_solutions = 0;
    int column = choose_first_column(inst, partial);
    for (int i = 0; i < inst->nb_rows; i++) {
        if (partial->remaining_rows[i] && inst->data[i][column]) {
            Partial* p2 = partial_copy(partial, inst->nb_rows, inst->nb_columns);
            select_row(inst, p2, i);
            nb_solutions += count(inst, p2);
            partial_free(p2);
        }
    }
    return nb_solutions;
}


bool search(Dense *inst, Partial *partial, Partial **solution, int p) {
    int nb_columns = 0;
    for (int j = 0; j < inst->nb_columns; j++) {
        if (partial->remaining_columns[j]) {
            nb_columns++;
            break;
        }
    }
    if (nb_columns == 0) {
        *solution = partial_copy(partial, inst->nb_rows, inst->nb_columns);;
        return true;
    }

    int nb_rows = 0;
    for (int i = 0; i < inst->nb_rows; i++) {
        if (partial->remaining_rows[i]) {
            nb_rows++;
            break;
        }
    }
    if (nb_rows == 0) return false;

    bool found = false;
    int column = choose_first_column(inst, partial);
    for (int i = 0; i < inst->nb_rows; i++) {
        if (partial->remaining_rows[i] && inst->data[i][column]) {
            Partial* p2 = partial_copy(partial, inst->nb_rows, inst->nb_columns);
            select_row(inst, p2, i);
            found = search(inst, p2, solution, p+1);
            partial_free(p2);
        }
        if (found) return true;
    }
    return false;
}


int main(int argc, char **argv) {
    if (argc < 3) {
        printf("Il faut passer en argument la taille du plateau (n p)");
        return 0;
    }
    int n = atoi(argv[1]);
    int p = atoi(argv[2]);
    Dense* inst = read_instance();
    Partial* partial = partial_new(inst);
    Partial* solution;
    if (search(inst, partial, &solution, 0)) {
        print_pentomino_solution(inst, solution, n, p);
        partial_free(solution);
    } else 
        printf("Pas de solution trouvée\n");
    dense_free(inst);
    partial_free(partial);
    return 0;
}
