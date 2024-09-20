#include <stdio.h>

int tv(int a) {
    int u = a;
    int n = 0;
    while (u != 1) {
        if (u % 2 == 0) u /= 2;
        else u = 3 * u + 1;
        n++;
    }
    return n;
}

int main(void) {
    int max = 0;
    int n = 0;
    for (int a = 1; a <= 10000; a++) {
        int t = tv(a);
        if (t > max) max = t;
        if (t > 20) n++;
    }
    printf("max(tv(a)|1 ≤ a ≤ 10000) = %d\n", max);
    printf("Nombre de a tels que tv(a) > 20 = %d", n);
    return 0;
}
