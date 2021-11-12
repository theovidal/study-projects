#include <stdio.h>

int s_one(int n) {
    int result = 0;
    for (int k = 1; k <= n; k++) {
        result += 2 * k + 1;
    }
    return result;
}

double s_two(int n) {
    double result = 0.0;
    for (int k = 1; k <= n; k++) {
        result += 1.0 / (k * k);
    }
    return result;
}

int s_three(int n) {
    int result = 0;
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) {
            result += i + j;
        }
    }
    return result;
}

int s_four(int n) {
    int result = 0;
    for (int i = 1; i <= n; i++) {
        for (int j = i; j <= n; j++) {
            result += i + j;
        }
    }
    return result;
}

int s_five(int n) {
    int result = 0;
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j < i; j++) {
            result += i + j;
        }
    }
    return result;
}

int main(void) {
    for (int i = 0; i < 4; i++) {
        printf("S1(%d) = %d\n", i, s_one(i));
        printf("S2(%d) = %.6f\n", i, s_two(i));
        printf("S3(%d) = %d\n", i, s_three(i));
        printf("S4(%d) = %d\n", i, s_four(i));
        printf("S5(%d) = %d\n", i, s_five(i));
    }
    return 0;
}
