#include <stdio.h>

void incremente(int * n) {
    *n += 1;
}

int main(void) {
    int n = 2;
    incremente(&n);
    printf("%d\n", n);
}
