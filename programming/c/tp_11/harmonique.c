#include <stdio.h>

int f(double x) {
    double h = 0;
    int k = 0;
    while (x > h) {
        k++;
        h += 1. / k; // La conversion en double se fait automatiquement
    }
    return k;
}

int main(void) {
    for (double i = 0; i <= 4.0; i += 0.5) {
        printf("f(%.1f) = %d\n", i, f(i));
    }
    return 0;
}
