#ifndef KDTREE
#define KDTREE

#include "min-heap.h"
#include "mnist_helper.h"

#define UNUSED __attribute__((unused))

typedef struct kdtree_def {
    struct kdtree_def *left;
    struct kdtree_def *right;
    struct kdtree_def *parent;
    size_t axis,size;
    mnist_case_t* node_ptr;
} kdtree_t;

// Given an array of cases, returns a pointer to the median one according to the given axis
mnist_case_t* find_median(mnist_case_t* case_array, size_t array_size, size_t axis);

// Build a k-d tree from the points contained in the dataset
kdtree_t* kdtree_build(mnist_dataset_t);

// Delete the k-d tree (but NOT the nodes it contains)
void kdtree_delete(kdtree_t*);

// Given a k-d tree and a vector, find its k closest neighbors in the tree
// Return their references in an array of k elements allocated on the heap
mnist_case_t** kdtree_knn(kdtree_t* tree, mnist_picture_t t_case, size_t array_size, size_t k);

#endif /* KDTREE */
