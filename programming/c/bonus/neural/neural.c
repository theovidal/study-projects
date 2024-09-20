#include "matrix.c"
#include "utils.c"

typedef struct Neural {
    int layers;

    Matrix** weights;
    Matrix** biases;
    Matrix** outputs;
} Neural;

void forward(Neural* neural, Matrix examples) {
    neural->outputs[0] = &examples;
    for (int i = 0; i < neural->layers - 1; i++) {
        Matrix result = sum(dot_product(*neural->outputs[i], *neural->weights[i]), *neural->biases[i]);
        apply_function(&result, sigmoid);
        neural->outputs[i + 1] = &result;
    }
}
