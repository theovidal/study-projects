#include <stdio.h>
#include <stdlib.h>

typedef struct {
    float* content;
    int* dimensions;
    int size;
    int dimension;
} Matrix;

void allocate_matrix(Matrix* matrix, int dimensions[]) {
    matrix->size = 1;
    matrix->dimensions = (int*)malloc(matrix->dimension * sizeof(int));
    for (int i = 0; i < matrix->dimension; i++) {
        matrix->dimensions[i] = dimensions[i];
        matrix->size *= dimensions[i];
    }

    matrix->content = (float*)malloc(matrix->size * sizeof(float));
}

void make_matrix(Matrix* matrix, int dimensions[], float x) {
    allocate_matrix(matrix, dimensions);
    for (int i = 0; i < matrix->size; i++) {
        matrix->content[i] = x;
    }
}

void make_matrix_from_array(Matrix* matrix, int dimensions[], float values[]) {
    allocate_matrix(matrix, dimensions);
    for (int i = 0; i < matrix->size; i++) {
        matrix->content[i] = values[i];
    }
}

int get_index(Matrix* matrix, int indexes[]) {
    int index = indexes[matrix->dimension - 1];
    int coef = 1;
    for (int i = matrix->dimension - 2; i >= 0; i--) {
        coef *= matrix->dimensions[i + 1];
        index += indexes[i] * coef;
    }
    return index;
}

float get_case(Matrix* matrix, int indexes[]) {
    return matrix->content[get_index(matrix, indexes)];
}

void set_case(Matrix *matrix, int indexes[], float x) {
    matrix->content[get_index(matrix, indexes)] = x;
}

void _sum_loop(Matrix* result, Matrix* m1, Matrix* m2, int iteration, int* iterations) {
    if (iteration == result->dimension) {
        float x1 = get_case(m1, iterations);
        float x2 = get_case(m2, iterations);
        set_case(result, iterations, x1 + x2);
    } else {
        for (int i = 0; i < result->dimensions[iteration]; i++) {
            iterations[iteration] = i;
            _sum_loop(result, m1, m2, iteration + 1, iterations);
        }
    }   
}

Matrix sum(Matrix m1, Matrix m2) {
    Matrix result;
    if (m1.dimension != m2.dimension) {
        result.dimension = -1;
        return result;
    }
    for (int i = 0; i < m1.dimension; i++) {
        if (m1.dimensions[i] != m2.dimensions[i]) {
            result.dimension = -1;
            return result;
        }
    }

    result.dimension = m1.dimension;
    allocate_matrix(&result, m1.dimensions);
    int* iterations = (int*)malloc(result.dimension * sizeof(int));
    _sum_loop(&result, &m1, &m2, 0, iterations);
    free(iterations);
    return result;
}

void free_matrix(Matrix *matrix) {
    free(matrix->dimensions);
    free(matrix->content);
}

int main(void) {
    Matrix matrix;
    matrix.dimension = 4;
    int dimensions[] = {3, 2, 3, 2};
    float values[] = {
        1, 2,
        3, 4,
        5, 6,

        7, 8,
        9, 10,
        11, 12,


        13, 14,
        15, 16,
        17, 18,

        19, 20,
        21, 22,
        23, 24,


        25, 26,
        27, 28,
        29, 30,

        31, 32,
        33, 34,
        35, 36,
    };

    make_matrix_from_array(&matrix, dimensions, values);
    int indexes[] = {1, 0, 2, 1};
    printf("%f\n", get_case(&matrix, indexes));

    Matrix m2;
    m2.dimension = 4;
    make_matrix_from_array(&m2, dimensions, values);
    Matrix result = sum(matrix, m2);
    printf("%f\n", get_case(&result, indexes));

    free_matrix(&matrix);
    free_matrix(&m2);
    free_matrix(&result);

    return 0;
}
