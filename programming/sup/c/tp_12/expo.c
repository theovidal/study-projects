#include <stdio.h>
#include <stdlib.h>

double expo(double x, int n) {
    double a = 1;
    double b = x;
    int p = n;
    while (p > 0) {
        if (p % 2 == 1) a *= b;
        b *= b;
        p /= 2;
    }
    return a;
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        printf("Il faut donner un flottant et un entier, putain.");
        return 1;
    }
    double x = atof(argv[1]);
    int n = atoi(argv[2]);
    printf("%.5f", expo(x, n));
    return 0;
}
