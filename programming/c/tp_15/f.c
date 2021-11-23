#include <stdio.h>

void f(int n, int* nmax) {
    printf("Début de l'appel de f(%d, _)\n", n);
    printf("n     = %d\n", n);
    printf("&n    = %p\n", &n);
    printf("nmax  = %p\n", nmax);
    printf("*nmax = %d\n", *nmax);
    printf("&nmax = %p\n", &nmax);
    if (n < *nmax) f(n + 1, nmax);
    printf("Fin de l'appel de f(%d, _)\n", n);
}

int main(void) {
    int N = 2;
    f(0, &N);
    return 0;
}
