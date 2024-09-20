#include <math.h>

float sigmoid(float x) {
    return 1.0 / (1.0 + exp(-x));
}

float sigmoid_prime(float x) {
    return sigmoid(x) * (1.0 - sigmoid(x));
}

float random(float _) {
    srand((int)time(NULL));
    return (float)rand() / 1000000000.0;
}

static const struct Matrix EmptyMatrix;

Matrix init_matrix(int rows, int cols) {
    Matrix matrix;
    matrix.rows = rows;
    matrix.cols = cols;
    make_matrix(&matrix, 0);
    apply_function(&matrix, random);
    return matrix;
}
