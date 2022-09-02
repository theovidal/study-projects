#ifndef BST_H
#define BST_H

typedef int item;
typedef struct BST bst;

bst* bst_make_empty(void);
void bst_free(bst* t);
void bst_insert(bst* t, item x);
bst* bst_from_array(item arr[], int len);
item bst_min(bst* t);
item bst_max(bst* t);
bool bst_member(bst* t, item x);
int bst_size(bst* t);
int bst_height(bst* t);
item* bst_to_array(bst* t, int* nb_elts);
void bst_delete(bst* t, item x);
void bst_in_order_print(bst* t);

#endif
