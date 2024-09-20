#include <stdio.h>

int fact(int n) {
    int result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}

int main(void) {
    for (int i = 0; i < 10; i++) {
        printf("%d! = %d\n", i, fact(i));
    }
    return 0;
}
