#include "../headers/kdtree.h"

void swap(mnist_case_t* array, int i, int j) {
    mnist_case_t temp = array[i];
    array[i] = array[j];
    array[j] = temp;
}

int partition(mnist_case_t *case_array, size_t array_size, size_t axis) {
    int ipiv = rand() % array_size;
    swap(case_array, 0, ipiv);
    int i = 1;
    for (int j = 1; j < array_size; j++) {
        if (case_array[j].picture[axis] <= case_array[0].picture[axis]) {
            swap(case_array, i, j);
            i++;
        }
    }
    swap(case_array, ipiv, i - 1);
    return i - 1;
}

mnist_case_t* quickselect(mnist_case_t *case_array, size_t array_size, size_t axis, int k) {
    if (array_size == 0) return NULL;
    int ipiv = partition(case_array, array_size, axis);
    if (k == ipiv) return &case_array[ipiv];
    else if (k < ipiv) return quickselect(case_array, ipiv, axis, k);
    else return quickselect(&case_array[ipiv + 1], array_size - ipiv - 1, axis, k - ipiv - 1);
}

mnist_case_t *find_median(mnist_case_t *case_array, size_t array_size, size_t axis)
{
    return quickselect(case_array, array_size, axis, array_size/2);
}

kdtree_t* kdtree_build_rec(mnist_case_t* case_array, size_t array_size, size_t axis, int dim) {
    if (array_size == 0) return NULL;
    kdtree_t* root = malloc(sizeof(kdtree_t));
    root->axis = axis;
    root->size = array_size;
    int med_id = array_size/2;
    mnist_case_t* med = find_median(case_array, array_size, axis);
    root->node_ptr = med;
    size_t next_axis = (axis + 1)%dim;

    root->left = kdtree_build_rec(case_array, med_id, next_axis, dim);
    if (root->left != NULL) root->left->parent = root;

    root->right = kdtree_build_rec(&case_array[med_id + 1], array_size - med_id - 1, next_axis, dim);
    if (root->right->parent != NULL)root->right->parent = root;

    return root;
}

kdtree_t* kdtree_build(mnist_dataset_t dataset)
{
    return kdtree_build_rec(dataset.cases, dataset.case_num, 0, dataset.width * dataset.height);
}

void kdtree_delete(kdtree_t* t)
{
    if (t->left != NULL) kdtree_delete(t->left);
    if (t->right != NULL) kdtree_delete(t->right);
    free(t);
}

void update(mnist_case_t* pt, int dist, min_heap* mh) {
    if (mh_size(*mh) < mh_capacity(*mh)) mh_insert(*mh, -dist, pt);
    else if (dist < -mh_first(*mh)->weight) {
        mh_pop(*mh);
        mh_insert(*mh, -dist, pt);
    }
}

void explore(kdtree_t* tree, mnist_picture_t t_case, size_t array_size, size_t k, min_heap* mh) {
    if (tree == NULL) return;
    update(tree->node_ptr, euclid_distance2(t_case, tree->node_ptr, tree->axis), mh);
    kdtree_t* to_explore;
    kdtree_t* remaining;
    int d = tree->node_ptr->picture[tree->axis];
    if (d < t_case[tree->axis]) {
        to_explore = tree->right;
        remaining = tree->left;
    } else {
        to_explore = tree->left;
        remaining = tree->right;
    }

    explore(to_explore, t_case, array_size, k, mh);

    if (pow(d - t_case[tree->axis], 2) < mh_first(*mh)->weight) explore(remaining, t_case, array_size, k, mh);
}

mnist_case_t **kdtree_knn(kdtree_t* tree, mnist_picture_t t_case, size_t array_size, size_t k)
{
    min_heap mh = mh_create(k);
    explore(tree, t_case, array_size, k, &mh);

    mnist_case_t** neighbours = malloc(k * sizeof(mnist_case_t*));
    for (int i = 0; i < k; i++) {
        neighbours[i] = (mnist_case_t*)mh_pop(mh);
    }
    mh_free(mh);
    return neighbours;
}  