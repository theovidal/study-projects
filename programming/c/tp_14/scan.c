#include <stdio.h>

int main(void) {
    int n = 0;
    int p = 0;

    float result = 0.;
    float l = 0.;
    scanf("%d %d", &n, &p);
    for (int i = 0; i < n; i++) {
        result = 0;
        for (int j = 0; j < p; j++) {
            scanf("%f", &l);
            result += l;
        }
        printf("%f\n", result);
    }
}
