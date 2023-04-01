#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "mnist_helper.h"
#include "kdtree.h"

static void swap_cases(mnist_case_t *c1, mnist_case_t *c2)
{
    mnist_case_t tmp = *c1;
    *c1 = *c2;
    *c2 = tmp;
}

static mnist_case_t generate_scalar_vector(int val, size_t size)
{
    mnist_case_t output = {.label = val, .picture = (int*)malloc(size*sizeof(int))};
    for(size_t i = 0; i < size; i++)
    {
        output.picture[i] = val;
    }
    return output;
}

static int test_median(size_t size, size_t dim)
{
    mnist_case_t *case_array = (mnist_case_t*)malloc(sizeof(mnist_case_t) * size);
    for(size_t i = 0; i < size; i++)
    {
        case_array[i] = generate_scalar_vector(i,dim);
    }

    // Shuffling: https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
    for(size_t i = 0; i < size-2; i++)
    {
        size_t j = i + (rand() % (size - i));
        swap_cases(&case_array[i],&case_array[j]);
    }

    // Median is still size/2; try the algorithm on some dimension
    size_t axis = rand() % dim;
    int median_output = find_median(case_array,size,axis)->label;

    for(size_t i = 0; i < size; i++)
    {
        free(case_array[i].picture);
    }
    free(case_array);

    return median_output;
}

int main()
{
    size_t testsize = 100;
    size_t testdim = 10;
    
    size_t testnum = 100;

    srand(43);

    for(size_t i = 0; i < testnum; i++)
    {
        size_t median_res = test_median(testsize,testdim);
        if (median_res != testsize/2)
        {
            fprintf(stderr,"Failed on test %llu\nGot %llu while expecting %llu (Total of %llu elements)\n",i,median_res,testsize/2, testsize);
            return 1;
        }
    }

    printf("Success !\n");
    return 0;
}