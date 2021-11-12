#include <stdio.h>

double expo_rapide_it(double x, int n) {
    double a = 1;
    double b = x;
    int p = n;
    // invariant : a * b^p = x^n
    while (p > 0) {
        if (p % 2 == 1) a *= b;
        b *= b;
        p /= 2;
    }
    return a;
}

double expo_rapide_rec(double x, int n) {
    if (n == 0) return 1;

    if (n % 2 == 0) return expo_rapide_rec(x * x, n/2);
    else return x * expo_rapide_rec(x * x, (n - 1)/2);
}

int main(void) {
    printf("3^9 = %.5f\n", expo_rapide_rec(3.0, 9));
    printf("4.5^12 = %.5f", expo_rapide_rec(4.5, 12));
    return 0;
}
