#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "bst.h"

int main(void) {
    bst* t = bst_make_empty();
    while (true) {
        int data;
        int read = scanf("%d ", &data);
        if (read < 1) break; // Attention, EOF correspond à -1, donc pas de ==0
        bst_insert(t, data);
    }
    bst_in_order_print(t);
    bst_free(t);
}
