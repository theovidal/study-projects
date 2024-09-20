#include <stdio.h>
#include <stdlib.h>

int max_inter(int* t, int n, int k) {
    int current = 0;
    int i_max = 0;

    for (int j = 0; j < k; j++) {
        current += t[j];
    }

    for (int j = 1; j < n - k; j++) {
        int old = current;
        current = current + t[j + k - 1] - t[j - 1];
        if (current > old) {
            i_max = j;
        }
        printf("%d\n", current);
    }

    return i_max;
}

int main(int _, char* argv[]) {
    int k = atoi(argv[1]);
    int size = atoi(argv[2]);

    int* t = (int*)malloc(size * sizeof(int));
    for (int i = 0; i < size; i++) {
        t[i] = atoi(argv[i + 3]);
    }

    printf("%d\n", max_inter(t, size, k));
    free(t);

    return 0;
}
