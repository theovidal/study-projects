#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef struct Matrix {
    float* content;
    int rows;
    int cols;
} Matrix;

void alloc_matrix(Matrix* matrix) {
    //if (matrix->content == NULL)
        matrix->content = (float*)malloc(matrix->rows * matrix->cols * sizeof(float));
}

void make_matrix(Matrix* matrix, float n) {
    alloc_matrix(matrix);
    for (int i = 0; i < matrix->rows * matrix->cols; i++) {
        matrix->content[i] = n;
    }
}

void make_matrix_from_array(Matrix* matrix, float array[]) {
    alloc_matrix(matrix);
    for (int i = 0; i < matrix->rows * matrix->cols; i++) {
        matrix->content[i] = array[i];
    }
}

float get_case(Matrix matrix, int row, int col) {
    return matrix.content[col + row * matrix.cols];
}

void set_case(Matrix* matrix, int row, int col, float n) {
    matrix->content[col + row * matrix->cols] = n; 
}

void make_identity_matrix(Matrix* matrix, int size) {
    matrix->rows = size;
    matrix->cols = size;
    make_matrix(matrix, 0);
    for (int i = 0; i < size; i++) {
        set_case(matrix, i, i, 1);
    }
}

void free_matrix(Matrix* matrix) {
    free(matrix->content);
}

Matrix transpose(Matrix matrix) {
    Matrix result;
    result.rows = matrix.cols;
    result.cols = matrix.rows;
    alloc_matrix(&result);
    for (int row = 0; row < matrix.rows; row++) {
        for (int col = 0; col < matrix.cols; col++) {
            set_case(&result, col, row, get_case(matrix, row, col));
        }
    }
    return result;
}

void apply_function(Matrix* matrix, float (*f)(float)) {
    for (int row = 0; row < matrix->rows; row++) {
        for (int col = 0; col < matrix->cols; col++) {
            float x = get_case(*matrix, row, col);
            set_case(matrix, row, col, (*f)(x));
        }
    }
}

Matrix sum(Matrix m1, Matrix m2) {
    Matrix matrix;

    if (m1.cols != m2.cols || m1.rows != m2.rows) {
        matrix.cols = -1;
        matrix.rows = -1;
        return matrix;
    }

    matrix.cols = m1.cols;
    matrix.rows = m1.rows;
    alloc_matrix(&matrix);

    for (int i = 0; i < matrix.rows; i++) {
        for (int j = 0; j < matrix.cols; j++) {
            float x1 = get_case(m1, i, j);
            float x2 = get_case(m2, i, j);
            set_case(&matrix, i, j, x1 + x2);
        }
    }
    return matrix;
}

Matrix dot_product(Matrix m1, Matrix m2) {
    Matrix matrix;

    if (m1.cols != m2.rows) {
        matrix.rows = -1;
        matrix.cols = -1;
        return matrix;
    }

    matrix.rows = m1.rows;
    matrix.cols = m2.cols;
    alloc_matrix(&matrix);

    for (int row = 0; row < matrix.rows; row++) {
        for (int col = 0; col < matrix.cols; col++) {
            float x = 0;
            for (int k = 0; k < m1.cols; k++) {
                x += get_case(m1, row, k) * get_case(m2, k, col);
            }
            set_case(&matrix, row, col, x);
        }
    }

    return matrix;
}

float square(float x) { return x * x; };

int main() {
    Matrix m1_pro;
    m1_pro.rows = 3;
    m1_pro.cols = 2;
    
    float pro_values[] = {
        1, 2,
        5, 3,
        6, 9
    };
    make_matrix_from_array(&m1_pro, pro_values);

    Matrix m1_max;
    m1_max.rows = 2;
    m1_max.cols = 4;
    
    float max_values[] = {
        2, 4, 1, 5,
        6, 2, 0, 3
    };
    make_matrix_from_array(&m1_max, max_values);

    Matrix* arr[] = {&m1_pro, &m1_max};

    Matrix result = dot_product(m1_pro, m1_max);
    apply_function(&result, square);
    for (int i = 0; i < result.rows; i++) {
        for (int j = 0; j < result.cols; j++) {
            printf("%f ", get_case(result, i, j));
        }
        printf("\n");
    }

    free_matrix(&m1_pro);
    free_matrix(&m1_max);
    free_matrix(&result);

    return 0;
}
