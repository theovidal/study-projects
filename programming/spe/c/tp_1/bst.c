#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <stdbool.h>

typedef int item;

struct Node {
  item key;
  struct Node *left;
  struct Node *right;
};

typedef struct Node node;

struct BST {
    node *root;
};

typedef struct BST bst;

node* new_node(item x){
  node* n = malloc(sizeof(node));
  n->key = x;
  n->left = NULL;
  n->right = NULL;
  return n;
}

bst *bst_make_empty(void){
    bst *t = malloc(sizeof(bst));
    t->root = NULL;
    return t;
}

void node_free(node *n){
  if (n == NULL) return;
  node_free(n->left);
  node_free(n->right);
  free(n);
}

void bst_free(bst *t){
    node_free(t->root);
    free(t);
}

node *node_insert(node *t, item x){
  if (t == NULL) {
    return new_node(x);
  }
  if (t->key < x) {
    t->right = node_insert(t->right, x);
  }
  else if (t->key > x) {
    t->left = node_insert(t->left, x);
  }
  return t;
}

void bst_insert(bst *t, item x){
    t->root = node_insert(t->root, x);
}

bst *bst_from_array(item arr[], int len){
  bst *t = bst_make_empty();
  for (int i = 0; i < len; i++){
    bst_insert(t, arr[i]);
  }
  return t;
}




item node_min(node *n){
  assert (n != NULL);
  while (n->left != NULL){
    n = n->left;
  }
  return n->key;
}

item bst_min(bst *t){
    return node_min(t->root);
}

item node_max(node *n){
    assert (n != NULL);
    while (n->right != NULL){
        n = n->right;
    }
    return n->key;
}


item bst_max(bst *t){
    return node_max(t->root);
}



bool node_member(node *n, item x){
    if (n == NULL) return false;
    item key = n->key;
    if (x == key) return true;
    if (x < key) return node_member(n->left, x);
    return node_member(n->right, x);
}

bool bst_member(bst *t, item x){
    return node_member(t->root, x);
}

void test_member(void){
    int n = 6;
    item arr[] = {50, 30, 20, 60, 40, 10};
    bst *t = bst_from_array(arr, 6);
    for (int i = 0; i < n; i++){
        assert(bst_member(t, arr[i]));
        assert(!bst_member(t, 1 + arr[i]));
    }
    printf("test_member : OK !");
}

int node_size(node *n){
    if (n == NULL) return 0;
    return node_size(n->left) + node_size(n->right) + 1;
}

int bst_size(bst *t){
    return node_size(t->root);
}

int max(int x, int y){
    if (x <= y) return x;
    return y;
}

int node_height(node *n){
    if (n == NULL) return -1;
    return 1 + max(node_height(n->left), node_height(n->right));
}

int bst_height(bst *t){
    return node_height(t->root);
}

void node_write_to_array(node *n, item arr[], int *offset_ptr){
    if (n == NULL) return;
    node_write_to_array(n->left, arr, offset_ptr);
    arr[*offset_ptr] = n->key;
    *offset_ptr = *offset_ptr + 1;
    node_write_to_array(n->right, arr, offset_ptr);
}

item *bst_to_array(bst *t, int *nb_elts){
    int len = node_size(t->root);
    *nb_elts = len;
    item *arr = malloc(len * sizeof(item));
    int offset = 0;
    node_write_to_array(t->root, arr, &offset);
    return arr;
}

node *node_extract_min(node *n, int *min_ptr){
  assert(n != NULL);
  if (n->left == NULL){
    node *result = n->right;
    *min_ptr = n->key;
    free(n);
    return result;
  }
  n->right = node_extract_min(n->left, min_ptr);
  return n;
}

node *node_delete(node *n, item x){
    if (n == NULL) return n;
    if (x < n->key) {
        n->left = node_delete(n->left, x);
        return n;
    }
    if (x > n->key) {
        n->right = node_delete(n->right, x);
        return n;
    }
    if (n->left == NULL) {
        node *result = n->right;
        free(n);
        return result;
    }
    if (n->right == NULL) {
        node *result = n->left;
        free(n);
        return result;
    }
    item successor = 0;
    n->right = node_extract_min(n->right, &successor);
    n->key = successor;
    return n;
}

void bst_delete(bst *t, item x){
    t->root = node_delete(t->root, x);
}


void node_in_order_print(node* n){
  if (n == NULL) return;
  node_in_order_print(n->left);
  printf(" %d ", n->key);
  node_in_order_print(n->right);
}

void bst_in_order_print(bst *t){
    node_in_order_print(t->root);
    printf("\n");
}
