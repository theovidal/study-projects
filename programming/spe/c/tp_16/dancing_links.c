#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>
#include <stdio.h>

struct node {
    struct node *up;
    struct node *down;
    struct node *left;
    struct node *right;
    struct node *header;
    int index;
    int data;
};

typedef struct node Node;


void print_solution(Node **solution, int k) {
    for (int i = 0; i < k; i++) {
        printf("%d", solution[i]->index);
        if (i < k - 1) printf(" - ");
    }
}


void print_torus(Node *root){
    printf("root count: %d\n", root->data);
    for (Node *c = root->right; c != root; c = c->right) {
        printf("%d: ", c->data);
        for (Node *r = c->down; r != c; r = r->down) {
            printf("%d ", r->data);
        }
        printf("\n");
    }
}


void remove_lr(Node *x) {
    x->left->right = x->right;
    x->right->left = x->left;    
}

void restore_lr(Node *x) {
    x->left->right = x;
    x->right->left = x;   
}

void remove_ud(Node *x) {
    x->up->down = x->down;
    x->down->up = x->up;
}

void restore_ud(Node *x) {
    x->up->down = x;
    x->down->up = x;
}


Node **create_node_matrix(bool **mat, int nb_rows, int nb_columns){
    int n = nb_rows;
    int p = nb_columns;
    Node **node_mat = malloc((n + 1) * sizeof(Node*));
    node_mat[n] = malloc((p + 1) * sizeof(Node));
    for (int i = 0; i < n; i++) {
        node_mat[i] = malloc(p * sizeof(Node));
    }
    for (int i = 0; i <= n; i++) {
        for (int j = 0; j < p; j++) {
            int left = (j == 0) ? p - 1 : j - 1;
            int right = (j == p - 1) ? 0 : j + 1;
            int down = (i == 0) ? n : i - 1;
            int up = (i == n) ? 0 : i + 1;
            node_mat[i][j].left = &node_mat[i][left];
            node_mat[i][j].right = &node_mat[i][right];
            node_mat[i][j].up = &node_mat[up][j];
            node_mat[i][j].down = &node_mat[down][j];
            node_mat[i][j].header = &node_mat[n][j];
            node_mat[i][j].data = i;
        }
    }
    for (int j = 0; j <= p; j++) {
        node_mat[n][j].data = 0;
        node_mat[n][j].index = j;
    }
    for (int i = 0; i < n; i++){
        for (int j = 0; j < p; j++) {
            if (!mat[i][j]) {
                remove_lr(&node_mat[i][j]);
                remove_ud(&node_mat[i][j]);
            }
            else {
                node_mat[n][j].data++;
            }
        }
    }
    node_mat[n][p].left = &node_mat[n][p - 1];
    node_mat[n][p - 1].right = &node_mat[n][p];
    node_mat[n][p].right = &node_mat[n][0];
    node_mat[n][0].left = &node_mat[n][p];
    node_mat[n][p].down = NULL;
    node_mat[n][p].up = NULL;
    node_mat[n][p].header = NULL;
    return node_mat;
}

Node *from_node_matrix(Node **node_mat, int nb_rows, int nb_columns){
    return &node_mat[nb_rows][nb_columns];
}

void free_node_matrix(Node **node_mat, int nb_rows){
    for (int i = 0; i <= nb_rows; i++) {
        free(node_mat[i]);
    }
    free(node_mat);
}

Node *choose_column(Node *root) {
    return root->right;
}

void cover_column(Node *c) {
    remove_lr(c);
    Node* cl = c->down;
    while (cl != c) {
        Node* ln = cl->right;
        while (ln != cl) {
            remove_ud(cl);
            ln->header->data--;
            ln = ln->right;
        }
        cl = cl->down;
    }
}

void uncover_column(Node *c) {
    Node* cl = c->up;
    while (cl != c) {
        Node* ln = cl->left;
        while (ln != cl) {
            restore_ud(cl);
            ln->header->data++;
            ln = ln->left;
        }
        cl = cl->up;
    }

    restore_lr(c);
}


void select_row(Node *n) {
    Node* ln = n->right;
    cover_column(n->header);
    while (ln != n) {
        cover_column(ln->header);
        ln = ln->right;
    }
}

void unselect_row(Node *n) {
    Node* ln = n->left;
    while (ln != n) {
        uncover_column(ln->header);
        ln = ln->left;
    }
    uncover_column(n->header);
}

void enumerate(Node *root, int k, Node **solution, bool print_flag) {
    printf("%d\n", k);
    if (root->right == root || k == 6) {
        if (print_flag) print_solution(solution, k);
        root->data++;
        return;
    }
    Node* c = choose_column(root);
    Node* i = c->down;
    while (i != c) {
        select_row(i);
        solution[k] = i;
        enumerate(root, k+1, solution, print_flag);
        unselect_row(i);
    }
}

bool **read_bool_matrix(int *n, int *p) {
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

void free_bool_matrix(bool **mat, int n) {
    for (int i = 0; i < n; i++) {
        free(mat[i]);
    }
    free(mat);
}

void print_matrix(bool **mat, int n, int p);

int main(void){
    int nb_rows, nb_columns;
    bool** mat = read_bool_matrix(&nb_rows, &nb_columns);
    Node** nmat = create_node_matrix(mat, nb_rows, nb_columns);
    Node* inst = from_node_matrix(nmat, nb_rows, nb_columns);

    Node** solution = malloc(nb_rows * sizeof(Node*));
    enumerate(inst, 0, solution, true);

    free_node_matrix(nmat, nb_rows);
    free_bool_matrix(mat, nb_rows);
    return 0;
}
