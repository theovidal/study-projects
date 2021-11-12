#include <stdio.h>

int min_while(int n) {
    int k = 0;
    while (1 << k < n) {
        k++;
    }
    return k;
}

int min_for(int n) {
    int k;
    for (k = 0; 1 << k < n; k++) {}
    return k;
}

int main(void) {
    printf("%d", min_for(5));
    return 0;
}
