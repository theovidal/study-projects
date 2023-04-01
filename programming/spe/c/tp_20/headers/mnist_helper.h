#ifndef MNIST_HELPER
#define MNIST_HELPER

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

// A picture is flattened in a row-major fashion.
// Since the size is the same for all pictures in the dataset, 
// there is no need to specify it for each picture.
typedef int* mnist_picture_t;
typedef int mnist_label_t;

typedef struct mnist_case_def
{
    mnist_picture_t picture; // The picture
    mnist_label_t label; // Its associated label
} mnist_case_t;

typedef struct mnist_dataset_def
{
    size_t height,width; // Pictures' dimensions
    size_t case_num; // Number of cases
    mnist_case_t* cases; // Array of cases
    mnist_label_t min_label, max_label; // Range for the labels
} mnist_dataset_t;



// Given the paths (as strings) for a MNIST-formated picture dataset (@param picture_dataset_path)
// and its associated label dataset (@param label_dataset_path),
// allocates and fill the @param cases array. Its size is put in @param case_num.
// @return 0 is successful, an error code otherwise
int parse_mnist(char* picture_dataset_path, char* label_dataset_path, mnist_dataset_t* parsed_dataset);


// Free the allocated memory in the @param dataset structure
void free_mnist_dataset(mnist_dataset_t* dataset);

// Printing MNIST-type greyscale pictures, because it is nice
void fprint_raw_mnist_pic(FILE* f, mnist_case_t* c, size_t height, size_t width);
void fprint_pretty_mnist_pic(FILE* f, mnist_case_t* c, size_t height, size_t width);  

void fprint_confusion_matrix(FILE* f, double* matrix, mnist_label_t min_label, mnist_label_t max_label);

#endif /* MNIST_HELPER */
