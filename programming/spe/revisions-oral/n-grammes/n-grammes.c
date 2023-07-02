#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

int plus_frequent_successeur(char c, char* chaine) {
    // Tableau contenant dans la case i
    // le nombre de caractères i suivant un caractère c
    int* occurences = malloc(128 * sizeof(int));

    for (int i = 0; i < 128; i++) {
        occurences[i] = 0;
    }
    int n = strlen(chaine);
    for (int i = 1; i < n; i++) {
        if (chaine[i - 1] == c) occurences[(int)chaine[i]]++;
    }

    int plus_frequent = 0;
    int nb_plus_frequent = 0;
    for (int i = 0; i < 128; i++) {
        if (occurences[i] > nb_plus_frequent) {
            plus_frequent = i;
            nb_plus_frequent = occurences[i];
        }
    }
    free(occurences);
    return plus_frequent;
}

int* init_modele(char* chaine) {
    int* grammes = malloc(128 * sizeof(int));
    for (int i = 0; i < 128; i++) {
        grammes[i] = plus_frequent_successeur(i, chaine);
    }
    return grammes;
}

int** matrice_confusion(int* M, char* test) {
    int** mat = malloc(128 * sizeof(int*));
    for (int i = 0; i < 128; i++) {
        mat[i] = malloc(128 * sizeof(int));
        for (int j = 0; j < 128; j++) {
            mat[i][j] = 0;
        }
    }
    int n = strlen(test);
    for (int i = 0; i < n - 1; i++) {
        char c = test[i];
        char suivant = test[i + 1];
        char predit = M[(int)c];
        mat[(int)predit][(int)suivant]++;
    }
    return mat;
}

void libere_matrice(int** mat) {
    for (int i = 0; i < 128; i++) {
        free(mat[i]);
    }
    free(mat);
}

double calcule_erreur(int** mat, int len) {
    int valeur_sans_diag = 0;
    int valeur_totale = 0;

    for (int i = 0; i < len; i++) {
        for (int j = 0; j < len; j++) {
            if (i != j) valeur_sans_diag += mat[i][j];
            valeur_totale += mat[i][j];
        }
    }
    if (valeur_totale == 0) return 1;
    else return (double)valeur_sans_diag / (double)valeur_totale;
}

int main(int _, char* argv[]) {
    char* chaine = "Bonjour, ca va bien ? Oui ! Bien mieux, et vous, ca va ?";
    int* modele = init_modele(chaine);
    int** mat = matrice_confusion(modele, chaine);
    printf("Taux d'erreur : %.3f\n", calcule_erreur(mat, 128));

    libere_matrice(mat);
    free(modele);

    return EXIT_SUCCESS;
}
