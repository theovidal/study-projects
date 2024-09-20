#include <stdio.h>

int n = 3;
int p;

int f(int n) {
    int* p = &n;
    int x = n + *p;
    return x + 1;
}

int g(int x, int y) {
    int z = f(x);
    return z + f(y);
}

int main(void) {
    p = 4;
    int result = g(n, p);
    printf("result = %d\n", result);
    return 0;
}
