#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <stdbool.h>

int max(int a, int b) {
    if (a >= b) return a;
    else return b;
}

typedef int item;

typedef struct Node {
  item key;
  struct Node* left;
  struct Node* right;
} Node;


typedef struct BST {
    Node* root;
} BST;

// Exercice 1

Node *new_node(item x) {
    Node* new = malloc(sizeof(Node));
    new->key = x;
    new->left = NULL;
    new->right = NULL;
    return new;
}

BST* bst_make_empty(void) {
    BST* new = malloc(sizeof(BST));
    new->root = NULL;
    return new;
}

void node_free(Node* n) {
    if (n != NULL) {
        node_free(n->left);
        node_free(n->right);
        free(n);
    }
}

void bst_free(BST* t) {
    node_free(t->root);
    free(t);
}

// Exercice 2

Node* node_insert(Node* n, item x) {
    if (n == NULL) {
        return new_node(x);
    }
    
    // Modification en place des arbres : on assigne le pointeur
    if (x > n->key) {
        n->right = node_insert(n->right, x);
    } else if (x < n->key) {
        n->left = node_insert(n->left, x);
    }
    return n;
}

void bst_insert(BST* t, item x) {
    // Même principe ici
    t->root = node_insert(t->root, x);
}

BST* bst_from_array(item arr[], int len) {
    BST* result = bst_make_empty();
    for (int i = 0; i < len; i++) {
        bst_insert(result, arr[i]);
    }
    return result;
}

// Exercice 3

item node_min(Node* n) {
    assert(n != NULL);

    if (n->left == NULL) return n->key;
    else return node_min(n->left);
}

item bst_min(BST* t) {
    return node_min(t->root);
}


bool node_member(Node* n, item x) {
    if (n == NULL) return false;

    if (x > n->key) return node_member(n->right, x);
    else if (x < n->key) return node_member(n->left, x);
    else return true;
}

bool bst_member(BST* t, item x) {
    return node_member(t->root, x);
}


int node_size(Node* n) {
    if (n == NULL) return 0;
    else return 1 + node_size(n->left) + node_size(n->right);
}

int bst_size(BST* t) {
    return node_size(t->root);
}

int node_height(Node* n) {
    if (n == NULL) return -1;
    else return 1 + max(node_height(n->left), node_height(n->right));
}

int bst_height(BST* t) {
    return node_height(t->root);
}

void node_write_to_array(Node* n, item arr[], int* offset_ptr) {
    if (n->left != NULL) node_write_to_array(n->left, arr, offset_ptr);

    arr[*offset_ptr] = n->key;
    (*offset_ptr)++;

    if (n->right != NULL) node_write_to_array(n->right, arr, offset_ptr);
}

item* bst_to_array(BST* t, int* nb_elts) {
    int size = bst_size(t);
    item* result = malloc(size * sizeof(item));
    *nb_elts = 0; // ATTENTION A L'ÉTOILE : on modifie la VALEUR, pas le POINTEUR
    node_write_to_array(t->root, result, nb_elts);
    return result;
}



// Exercice 4

Node* node_extract_min(Node* n, int* min_ptr) {
    assert(n != NULL);

    if (n->left == NULL) {
        *min_ptr = n->key;
        Node* tmp = n;
        n = n->right;
        free(tmp);
        return n;
    }
    n->left = node_extract_min(n->left, min_ptr);
    return n;
}

// 6 cas différents, pour le dernier (existence de sous-arbre gauche ET droit)
//  On supprime le minimum du sous-arbre droit et on le place sur l'étiquette supprimée
Node* node_delete(Node* n, item x) {
    assert(n != NULL);

    if (n->key == x) {
        Node* tmp = n;
        if (n->left == NULL) {
            n = n->right;
            free(tmp);
        } else if (n->right == NULL) {
            n = n->left;
            free(tmp);
        } else {
            int min = 0;
            n->right = node_extract_min(n->right, &min);
            n->key = min;
        }
    }
    else if (x < n->key) n->left = node_delete(n->left, x);
    else n->right = node_delete(n->right, x);
    
    return n;
}

void bst_test(void) {
    int n = 6;
    item arr[] = {50, 30, 20, 60, 40, 10};
    BST* t = bst_from_array(arr, 6);
    for (int i = 0; i < n; i++){
        assert(bst_member(t, arr[i]));
        assert(!bst_member(t, 1 + arr[i]));
    }
    node_delete(t->root, 30);
    int nb_elts = 0;
    item* res = bst_to_array(t, &nb_elts);
    for (int i = 0; i < nb_elts; i++) {
        printf("%d ", res[i]);
    }
    bst_free(t);
    free(res);
    printf("test OK!");
}


// Exercice 5

// rand_between(lo, hi) return a random integer
// between lo (inclusive) and hi (exclusive).
//
// Not perfectly uniform, but close enough
// provided hi - lo << RAND_MAX.

int rand_between(int lo, int hi){
    int x = rand();
    return lo + x % (hi - lo);
}

// Shuffles (applies a random permutation to) the argument array.
// This will be uniform
// provided the function rand_between is (which is not
// quite the case here, but it won't make any difference
// in practice).

void shuffle(item arr[], int len){
    assert(len < RAND_MAX);
    for (int i = 0; i < len; i++){
        int j = rand_between(i, len);
        item tmp = arr[i];
        arr[i] = arr[j];
        arr[j] = tmp;
    }
}


int main(int argc, char *argv[]){
    if (argc < 3) {
        printf("Il faut passer deux entiers en argument");
        return -1;
    }
    int max_power = atoi(argv[1]);
    int rep_count = atoi(argv[2]);

    for (int k = 4; k <= max_power; k++) {
        int avg = 0;
        int len = 1 << k;
        for (int c = 0; c < rep_count; c++) {
            item* arr = malloc(len * sizeof(item));
            for (int i = 0; i < len; i++) {
                arr[i] = i;
            }
            shuffle(arr, len);
            BST* t = bst_from_array(arr, len);

            avg += bst_height(t);
            free(arr);
            bst_free(t);
        }
        avg /= rep_count;
        printf("%d %d\n", len, avg);
    }

    return 0;
}
