#include "min-heap.h"

#define UNUSED __attribute__((unused))

// ----- Creation ----- //

static void init_node(heap_node_t *n, size_t index)
{
    n->data = NULL;
    n->index = index;
    n->size = 0;
    n->weight = NAN;
}

static size_t next_pow2(size_t n)
{
    size_t out = 1;
    while(n != 0)
    {
        n = n >> 1;
        out = out << 1;
    }
    return out;
}

min_heap mh_create(size_t n)
{
    size_t cap = next_pow2(n);
    heap_node_t *array = malloc(cap * sizeof(heap_node_t));
    min_heap output = {.capacity = cap, .array = array};
    for (size_t i = 0; i < cap; i++)
    {
        init_node(&array[i], i);
    }
    return output;
}

// ----- Deletion ----- //

void mh_free(min_heap h)
{
    if (h.array == NULL)
        return;
    else
    {
        free(h.array);
        h.array = NULL;
        h.capacity = 0;
    }
}

// ----- Size test ----- //

bool mh_empty(min_heap h)
{
    return mh_size(h) == 0;
}

size_t mh_size(min_heap h)
{
    return h.array[0].size;
}

size_t mh_capacity(min_heap h)
{
    return h.capacity;
}

static bool node_empty(heap_node_t *node)
{

    return node == NULL || node->size == 0;
}

// ----- Access ----- //

static size_t left_child_index(size_t i)
{
    return 2 * i + 1;
}

static size_t right_child_index(size_t i)
{
    return 2 * i + 2;
}

static size_t parent_index(size_t i)
{
    return (i - 1) / 2;
}

static heap_node_t *left_child(min_heap h, heap_node_t *node)
{
    size_t target_index = left_child_index(node->index);
    if (target_index >= h.capacity)
    {
        return NULL;
    }
    else
    {
        return &h.array[target_index];
    }
}

static heap_node_t *right_child(min_heap h, heap_node_t *node)
{
    size_t target_index = right_child_index(node->index);
    if (target_index >= h.capacity)
    {
        return NULL;
    }
    else
    {
        return &h.array[target_index];
    }
}

static heap_node_t *parent(min_heap h, heap_node_t *node)
{
    size_t target_index = parent_index(node->index);
    if (target_index >= h.capacity)
    {
        return NULL;
    }
    else
    {
        return &h.array[target_index];
    }
}

// ----- Move data in the structure ----- //

static void swap_contents(heap_node_t *n1, heap_node_t *n2)
{
    void *tmp_data = n1->data;
    double tmp_weight = n1->weight;

    n1->data = n2->data;
    n1->weight = n2->weight;

    n2->data = tmp_data;
    n2->weight = tmp_weight;
}

void mh_percolate_up(min_heap h, heap_node_t *n)
{
    heap_node_t *up_node = parent(h, n);
    if (up_node == NULL)
        return;

    if (n->weight < up_node->weight)
    {
        swap_contents(n, up_node);
        mh_percolate_up(h, up_node);
    }
}

void mh_percolate_down(min_heap h, heap_node_t *n)
{
    heap_node_t *left_node = left_child(h, n);
    heap_node_t *right_node = right_child(h, n);

    if (left_node == NULL && right_node == NULL)
        return;
    else
    {
        if (node_empty(left_node) && node_empty(right_node))
        {
            return;
        }

        if (node_empty(left_node) && !node_empty(right_node))
        {
            if (right_node->weight < n->weight)
            {
                swap_contents(n, right_node);
                mh_percolate_down(h, right_node);
            }
            else
            {
                return;
            }
        }

        if (!node_empty(left_node) && node_empty(right_node))
        {
            if (left_node->weight < n->weight)
            {
                swap_contents(n, left_node);
                mh_percolate_down(h, left_node);
            }
            else
            {
                return;
            }
        }

        // if (!node_empty(left_node) && !node_empty(right_node))
        {
            // If the minimum is in the right child
            if (right_node->weight <= n->weight && right_node->weight <= left_node->weight)
            {
                swap_contents(right_node, n);
                mh_percolate_down(h, right_node);
            }
            // If the minimum is in the left child
            else if (left_node->weight <= n->weight && left_node->weight <= right_node->weight)
            {
                swap_contents(left_node, n);
                mh_percolate_down(h, left_node);
            }
            // Otherwise there is nothing to do
            return;
        }
    }
}

// ----- Interaction with the structure ----- //

static int insert(min_heap h, heap_node_t *node, double w, void *d)
{
    if (node_empty(node))
    {
        node->data = d;
        node->weight = w;
        node->size = 1;
        return 0;
    }
    else
    {
        // By construction, either none or both children exists (but they may be empty)
        heap_node_t *left_node = left_child(h, node);
        heap_node_t *right_node = right_child(h, node);

        // No children, no insertion possible...
        if (left_node == NULL && right_node == NULL)
        {
            return -1;
        }
        else
        {
            node->size++;

            if (left_node->size <= right_node->size)
            {
                int res = insert(h, left_node, w, d);

                if (res == -1)
                    return -1;
                else
                {
                    // Percolate up
                    if (left_node->weight < node->weight)
                    {
                        swap_contents(left_node, node);
                    }
                    return res;
                }
            }
            else
            {
                int res = insert(h, right_node, w, d);

                if (res == -1)
                    return -1;
                else
                {
                    // Percolate up
                    if (right_node->weight < node->weight)
                    {
                        swap_contents(right_node, node);
                    }
                    return res;
                }
            }
        }
    }
}

int mh_insert(min_heap h, double w, void *d)
{
    // If there is no room left...
    if (h.capacity <= h.array[0].size)
    {
        return -1;
    }
    else
    {
        return insert(h, &h.array[0], w, d);
    }
}

static heap_node_t *pop_bottom(min_heap h, heap_node_t *n)
{
    if (n->size == 0)
    {
        return NULL;
    }
    else if (n->size == 1)
    {
        n->size = 0;
        return n;
    }
    else
    {
        n->size--;
        heap_node_t *left_node = left_child(h, n);
        heap_node_t *right_node = right_child(h, n);

        if (left_node->size > right_node->size)
        {
            return pop_bottom(h, left_node);
        }
        else
        {
            return pop_bottom(h, right_node);
        }
    }
}

void *mh_pop(min_heap h)
{
    if (mh_empty(h))
        return NULL;
    else
    {
        void *output = h.array[0].data;
        heap_node_t *bottom_node = pop_bottom(h, &h.array[0]);
        swap_contents(bottom_node, &h.array[0]);
        init_node(bottom_node,bottom_node->index);
        mh_percolate_down(h, &h.array[0]);
        return output;
    }
}

void mh_modify_weight(min_heap h, heap_node_t *n, double new_weight)
{
    if (new_weight < n->weight)
    {
        n->weight = new_weight;
        mh_percolate_up(h,n);
    }
    else if (new_weight > n->weight)
    {
        n->weight = new_weight;
        mh_percolate_down(h,n);
    }
    // If the new weight is the same, there is nothing to do
}

// ----- Inspection ----- //

void* mh_get_data(heap_node_t* n)
{
    return n->data;
}

// ----- Iterator ----- //

heap_node_t* mh_first(min_heap h)
{
    if (mh_empty(h))
        return NULL;
    else
        return &h.array[0];
}

heap_node_t* mh_end(UNUSED min_heap h)
{
    return NULL;
}

heap_node_t* mh_next(min_heap h,heap_node_t* n)
{
    size_t next_index = n->index+1;

    // Check if we are at the end
    if (next_index >= h.capacity)
    {
        return NULL;
    }
    else
    {
        heap_node_t* next_node = &h.array[next_index];

        // If the following node is empty, returns the next viable
        if (next_node->size == 0)
        {
            return mh_next(h,next_node);
        }
        else
        {
            return next_node;
        }
    }
}

