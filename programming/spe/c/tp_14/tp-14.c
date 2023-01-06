#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include "dicts.h"

int min(int a, int b) {
    if (a >= b) return b;
    else return a;
}

int max(int a, int b) {
    if (a >= b) return a;
    else return b;
}

struct TTT {
    int n;
    int k;
    int* grille;
};

typedef struct TTT ttt;

ttt* init_jeu(int k, int n) {
    int* grille = malloc(n * n * sizeof(int));
    for (int i = 0; i < n * n; i++) {
        grille[i] = 0;
    }
    ttt* jeu = malloc(sizeof(ttt));
    jeu->n = n;
    jeu->k = k;
    jeu->grille = grille;
    return jeu;
}

void liberer_jeu(ttt* jeu) {
    free(jeu->grille);
    free(jeu);
}

int* repartition(ttt* jeu) {
    int* rep = malloc(3 * sizeof(int));
    rep[0] = 0;
    rep[1] = 0;
    rep[2] = 0;
    for (int i = 0; i < jeu->n * jeu->n; i++) {
        int v = jeu->grille[i];
        assert(v >= 0 && v <= 2);
        rep[v]++;
    }
    return rep;
}

int joueur_courant(ttt* jeu) {
    int* rep = repartition(jeu);
    int player = 0;
    if (rep[0] == 0) player = 0;
    else if (rep[1] == rep[2]) player = 1;
    else player = 2;
    free(rep);
    return player;
}

bool jouer_coup(ttt* jeu, int lgn, int cln) {
    int i = jeu->n * lgn + cln;
    if (i < 0 || i >= jeu->n * jeu->n) {
        printf("Cette case n'existe pas !\n");
        return false;
    }
    if (jeu->grille[i] != 0) {
        printf("La case n'est pas vide !\n");
        return false;
    }
    else jeu->grille[i] = joueur_courant(jeu);
    return true;
}

bool alignement(ttt* jeu, int i, int di, int joueur) {
    int lgn = i / jeu->n;
    int cln = i % jeu->n;
    int dl = (di + 1)/jeu->n;
    int dc = (di + 1)%jeu->n - 1;
    int detectes = 0;
    for (int j = 0; j < jeu->k; j++) {
        if (lgn < 0 || lgn >= jeu->n || cln < 0 || cln >= jeu->n) return false;
        if (jeu->grille[i] != joueur) return false;
        i += di;
        lgn += dl; cln += dc;
        detectes++;
    }
    return true;
}

bool gagnant(ttt* jeu, int joueur) {
    int dis[4] = {1, jeu->n - 1, jeu->n, jeu->n + 1};
    for (int i = 0; i < jeu->n * jeu->n; i++) {
        for (int j = 0; j < 4; j++) {
            if (alignement(jeu, i, dis[j], joueur)) return true;
        }
    }
    return false;
}

int encodage(ttt* jeu) {
    int code = 0;
    for (int i = 0; i < jeu->n * jeu->n; i++) {
        code = code * 3 + jeu->grille[i];
    }
    return code;
}

int attracteur(ttt* jeu, dict* d) {
    int code = encodage(jeu);
    if (!member(d, code)) {
        int joueur = joueur_courant(jeu);
        int autre = 3 - joueur;
        if (joueur == 0) add(d, code, 0);                       // Cas partie nulle
        if (gagnant(jeu, joueur)) add(d, code, joueur);
        else if (gagnant(jeu, autre)) add(d, code, autre);
        else {
            int tab[3] = {0, 0, 0};
            for (int k = 0; k < jeu->n * jeu->n; k++) {
                if (jeu->grille[k] == 0) {
                    jeu->grille[k] = joueur;
                    int att = attracteur(jeu, d);
                    jeu->grille[k] = 0;
                    tab[att]++;

                    if (att == joueur) break;
                }
            }
            if (tab[joueur] != 0) add(d, code, joueur);
            else if (tab[0] != 0) add(d, code, 0);
            else add(d, code, autre);
        }
    }
    return get(d, code);
}

int strategie_optimale(ttt* jeu, dict* d) {
    int joueur = joueur_courant(jeu);
    int att = attracteur(jeu, d);
    
    for (int i = 0; i < jeu->n * jeu->n; i++) {
        if (jeu->grille[i] == 0) {
            jeu->grille[i] = joueur;
            int att_succ = attracteur(jeu, d);
            jeu->grille[i] = 0;

            if (att_succ == att) return i;
        }
    }
    return -1;
}

char pion(int joueur) {
    switch(joueur) {
        case 0:
            return ' ';
        case 1:
            return 'X';
        case 2:
            return 'O';
    }
    return ' ';
}

void afficher_separateur(int n) {
    printf("\n ");
    for (int i = 0; i < n; i++) {
        printf("+-");
    }
    printf("+\n");
}

void afficher(ttt* jeu) {
    for (int i = 0; i < jeu->n;i++) {
        printf(" %d", i);
    }
    for (int i = 0; i < jeu->n * jeu->n; i++) {
        int lgn = i/jeu->n;
        int cln = i%jeu->n;
        if (cln == 0) {
            afficher_separateur(jeu->n);
            printf("%d|", lgn);
        } 
        printf("%c|", pion(jeu->grille[i]));
    }
    afficher_separateur(jeu->n);
    printf("\n");
}

void jouer_partie(int k, int n) {
    char c;
    printf("Commencer ? (o/n)");
    scanf("%c", &c);
    int ordi = 1;
    int joueur = 2;
    if (c == 'o') {
        ordi = 2;
        joueur = 1;
    }

    ttt* jeu = init_jeu(k, n);
    dict* d = create();
    int nb = 0;
    if (ordi == 1) {
        jeu->grille[n + n / 2] = ordi;
        nb++;
    }
    afficher(jeu);

    for (;;) {
        int lgn;
        int cln;
        bool valid = false;
        while (!valid) {
            printf("%d\n", joueur_courant(jeu));
            printf("Saisir: ligne colonne > ");
            scanf("%d %d", &lgn, &cln);
            valid = jouer_coup(jeu, lgn, cln);
        }

        afficher(jeu);
        if (gagnant(jeu, joueur)) {
            printf("Bravo, vous avez gagné contre l'ordinateur!");
            break;
        }
        nb++;
        if (nb == jeu->n * jeu->n) {
            printf("La partie est nulle");
            break;
        }

        int i = strategie_optimale(jeu, d);
        jeu->grille[i] = ordi;
        afficher(jeu);
        if (gagnant(jeu, ordi)) {
            printf("L'ordinateur vous a battu... retentez votre chance!");
            break;
        }
        nb++;
        if (nb == jeu->n * jeu->n) {
            printf("La partie est nulle");
            break;
        }
    }
    liberer_jeu(jeu);
    dict_free(d);
}

int main(int argc, char* argv[]){
    if (argc < 3) {
        printf("Il faut donner un nombre de symboles et une taille de grille");
        return 1;
    }
    int k = atoi(argv[1]);
    int n = atoi(argv[2]);
    jouer_partie(k, n);
    return 0;
}