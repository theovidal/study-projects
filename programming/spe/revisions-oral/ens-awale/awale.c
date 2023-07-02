#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

int** Dw7;
int** Dw24;
int nDw7, nDw24;

int** creer_configurations(int* nDw, const char* nom_fichier){
    FILE* fichier = fopen(nom_fichier, "r");
    fscanf(fichier, "%d", nDw);
    int** Dw = malloc(*nDw * sizeof(*Dw));
    for (int i=0; i<*nDw; i++){
        Dw[i] = malloc(8 * sizeof(int));
        for (int j=0; j<8; j++){
            fscanf(fichier, "%d", &Dw[i][j]);
        }
    }
    fclose(fichier);
    return Dw;
}

void detruire_configurations(int** Dw, int nDw){
    for (int i=0; i<nDw; i++){
        free(Dw[i]);
    }
    free(Dw);
}

void afficher_tab(int* tab){
    printf("{%d", tab[0]);
    for (int i=1; i<8; i++){
        printf(", %d", tab[i]);
    }
    printf("}\n");
}

void jouer(int* tab, int c) {
    int nb_graines = tab[c];
    tab[c] = 0;
    for (int k = 1; k <= nb_graines; k++) {
        int indice = (c + k) % 8;
        if (indice != c) tab[indice]++;
    }
    int derniere_case = (c + nb_graines) % 8;
    int recoltes = 0;
    
}

int n_peut_plus_jouer(int* tab) {
    
}

int main(void){
    Dw7 = creer_configurations(&nDw7, "configurations_7.txt");
    Dw24 = creer_configurations(&nDw24, "configurations_24.txt");
    // Les deux lignes suivantes peuvent être effacées après avoir comparé
    // avec les résultats de la question 4.
    for (int i=1; i<4; i++) afficher_tab(Dw7[i]);
    for (int i=4; i<7; i++) afficher_tab(Dw24[i]);




    detruire_configurations(Dw7, nDw7);
    detruire_configurations(Dw24, nDw24);
    return EXIT_SUCCESS;
}