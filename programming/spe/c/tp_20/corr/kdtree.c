#include "kdtree.h"

static void swap_cases(mnist_case_t *c1, mnist_case_t *c2)
{
    mnist_case_t tmp = *c1;
    *c1 = *c2;
    *c2 = tmp;
}

static mnist_case_t *find_nth(mnist_case_t *case_array, size_t array_size, size_t axis, size_t n)
{
    int pivot_value = case_array[0].picture[axis];

    size_t lesser_index = 1;
    size_t greater_index = array_size - 1;

    while (lesser_index <= greater_index)
    {
        int candidate_value = case_array[lesser_index].picture[axis];
        if (candidate_value <= pivot_value)
        {
            lesser_index++;
        }
        else
        {
            swap_cases(&case_array[lesser_index], &case_array[greater_index]);
            greater_index--;
        }
    }

    size_t smaller_count = lesser_index;
    if (smaller_count-1 == n)
    {
        return &case_array[0];
    }
    else if (smaller_count-1 < n)
    {
        return find_nth(&case_array[lesser_index], array_size - smaller_count, axis, n - smaller_count);
    }
    else
    {
        return find_nth(&case_array[1], smaller_count - 1, axis, n);
    }
}

mnist_case_t *find_median(mnist_case_t *case_array, size_t array_size, size_t axis)
{
    return find_nth(case_array, array_size, axis, array_size / 2);
}

static kdtree_t rec_kdtree_build(mnist_case_t *case_array, size_t array_size, size_t axis, size_t dimensions)
{
    mnist_case_t *median_case = find_median(case_array, array_size, axis);
    kdtree_t output = {.axis = axis,
                       .left = NULL,
                       .right = NULL,
                       .parent = NULL,
                       .node_ptr = median_case,
                       .size = array_size};

    if (array_size == 1)
    {
        return output;
    }
    else if (array_size == 2)
    {
        output.left = (kdtree_t*) malloc(sizeof(kdtree_t));
        *output.left = rec_kdtree_build(case_array,1,(axis+1) % dimensions, dimensions);
        output.left->parent = &output;

        return output;
    }
    else
    {
       output.left = (kdtree_t*) malloc(sizeof(kdtree_t));
        *output.left = rec_kdtree_build(case_array,array_size/2,(axis+1) % dimensions, dimensions);
        output.left->parent = &output;

        output.right = (kdtree_t*) malloc(sizeof(kdtree_t));
        *output.right = rec_kdtree_build(&case_array[1+(array_size/2)],array_size - (1+(array_size/2)),(axis+1) % dimensions, dimensions); 
        output.right->parent = &output;

        return output;
    }
}

kdtree_t kdtree_build(mnist_dataset_t dataset)
{
    return rec_kdtree_build(dataset.cases,dataset.case_num,0,dataset.height*dataset.width);
}

void kdtree_delete(kdtree_t t)
{
    if (t.left != NULL)
    {
        kdtree_delete(*t.left);
        free(t.left);
    }

    if (t.right != NULL)
    {
        kdtree_delete(*t.right);
        free(t.right);
    }

    t.size = 0;
    t.node_ptr = NULL;
}

mnist_case_t **kdtree_knn(UNUSED kdtree_t tree, UNUSED mnist_picture_t t_case, UNUSED size_t array_size, UNUSED size_t k)
{
    fprintf(stderr, "Fonction 'kdtree_knn' non implémentée!\nFin du programme...");
    exit(1);
}