#include <stdio.h>
#include <stdlib.h>
#include <time.h>

const int taille = 10;
int tab[10];

void remplire(void) {
    srand((int)time(NULL));
    for (int i = 0; i < taille; i++) {
        tab[i] = rand() / 10000000;
    }
}

void affiche(void) {
    for (int i = 0; i < taille; i++) {
        printf("%d ", tab[i]);
    }
    printf("\n");
}

int min(void) {
    int m = tab[0];
    for (int i = 1; i < taille; i++) {
        if (tab[i] < m) m = tab[i];
    }
    return m;
}

int indice_min(void) {
    int m = tab[0];
    int indice = 0;
    for (int i = 1; i < taille; i++) {
        if (tab[i] < m) {
            m = tab[i];
            indice = i;
        }
    }
    return indice;
}

void echange(int i, int j) {
    int temp = tab[i];
    tab[i] = tab[j];
    tab[j] = temp;
}

void tri_insertion(void) {
    for (int n = 1; n < taille; n++) {
        for (int i = n; i > 0; i--) {
            if (tab[i] >= tab[i - 1]) break;
            echange(i, i-1);
        }
    }
}

int main(void) {
    remplire();
    affiche();
    printf("Minimum = %d\n", min());
    printf("Indice = %d\n\n", indice_min());
    tri_insertion();
    affiche();
    return 0;
}
