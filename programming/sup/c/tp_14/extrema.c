#include <stdio.h>

int tableau[] = {2, 5, 4, 1, 7, 3, 9, 1, 5, 3, 6, 1};
int taille = 12;

void extrema(int t[], int taille, int* min, int* max) {
    for (int i = 0; i < taille; i++) {
        if (t[i] < *min) *min = t[i];
        if (t[i] > *max) *max = t[i];
    }
}

int main(void) {
    int max = tableau[0];
    int min = tableau[0];
    extrema(tableau, taille, &min, &max);
    printf("min = %d; max = %d\n", min, max);
    return 0;
}
