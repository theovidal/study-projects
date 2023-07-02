#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct sac {
    int nb_objets;
    int* valeurs;
    int* poids;
} sac;

sac* cree_sac(int nb_objets) {
    sac* inst = malloc(sizeof(sac));
    inst->nb_objets = nb_objets;
    inst->valeurs = malloc(nb_objets * sizeof(int));
    inst->poids = malloc(nb_objets * sizeof(int));
    return inst;
}

bool* resout(sac* inst, int pmax) {
    bool* sol = malloc(inst->nb_objets * sizeof(bool));
    int poids = 0;
    for (int i = 0; i < inst->nb_objets; i++) {
        if (poids + inst->poids[i] <= pmax) {
            poids += inst->poids[i];
            sol[i] = true;
        } else sol[i] = false;
    }
    return sol;
}

void detruit_sac(sac* inst) {
    free(inst->valeurs);
    free(inst->poids);
    free(inst);
}

int main(void) {
    int nb_objets;
    int pmax;
    scanf("%d %d", &nb_objets, &pmax);
    sac* inst = cree_sac(nb_objets);
    for (int i = 0; i < nb_objets; i++) {
        int valeur;
        scanf("%d", &valeur);
        inst->valeurs[i] = valeur;
    }
    for (int i = 0; i < nb_objets; i++) {
        int poids;
        scanf("%d", &poids);
        inst->poids[i] = poids;
    }
    bool* sol = resout(inst, pmax);
    for (int i = 0; i < inst->nb_objets; i++)
    detruit_sac(inst);
}


int une_occurrence(int n, int* tab, int x) {
    int d = 0;
    int f = n - 1;
    int res = -1;
    while (d <= f) {
        int m = (d + f) / 2;
        if (tab[m] == x) {
            res = m;
            break;
        } else if (tab[m] < x) {
            d = m + 1;
        } else {
            f = m - 1;
        } 
    }
    return res;
}
