#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>
#include <time.h>

struct processus {
  char *exec;
  int pid;
};

typedef struct processus processus;

struct process {
  processus *actif;
  struct process *suivant;
  struct process *precedent;
};

typedef struct process process;


processus *lance_processus(char *exec) {

  // Variable allouée une fois pour tout en tout début de programme et
  // partagée par tous les appels, grâce au mot-clé `static` [HP]
  static int next_pid = 0;

  processus* p = malloc(sizeof(processus));

  // On va copier le nom, être responsable de libérer la mémoire
  // allouée mais pas celle du pointeur passé en paramètre
  p->exec = malloc(1 + strlen(exec));
  strcpy(p->exec, exec);
  p->pid = next_pid;
  next_pid++;

  // Lancement fictif du processus
  printf("* Lancement du processus %s\n", p->exec);

  return p;

}

// Comportement aléatoire juste pour tester
bool est_fini(processus *p) {
  assert (p != NULL);  // Surtout pour ignorer l'avertissement
  if (rand() % 10 == 0) {
    return true;
  } else {
    return false;
  }
}

void arrete(processus *p) {

  // Arrêt fictif du processus
  printf("* Arrêt du processus %s\n", p->exec);

  free(p->exec);
  free(p);

}

void cpu_quantum(processus *p) {

  assert(p != NULL);

  // Fait tourner fictivement le processus p

  return;
}

void ps(process** ordonnanceur) {
    process* p = (*ordonnanceur)->suivant;
    printf("PID   CMD\n");
    while (p != *ordonnanceur) {
        printf("%d    %s\n", p->actif->pid, p->actif->exec);
        p = p->suivant;
    }
}

void ajoute_process(process** ordonnanceur, processus* p) {
    assert(p != NULL);
    process* new = malloc(sizeof(process));
    new->actif = p;
    if (*ordonnanceur == NULL) {
      new->suivant = new;
      new->precedent = new;
      *ordonnanceur = new;
    } else {
      new->suivant = *ordonnanceur;
      new->precedent->suivant = new;
      new->precedent = (*ordonnanceur)->precedent;
      (*ordonnanceur)->precedent = new;
    }
}

// Ne pas oublier les assert pour vérifier la validité de l'argument :
// on suppose qu'il y a au moins un autre maillon dans la file
void delete(process* maillon) {
    assert(maillon->suivant != maillon && maillon->precedent != maillon);
    maillon->suivant->precedent = maillon->precedent;
    maillon->precedent->suivant = maillon->suivant;
    arrete(maillon->actif);
    free(maillon);
}

void delete_current(process** ordonnanceur) {
    assert(*ordonnanceur != NULL);
    process* current = *ordonnanceur;
    if (current == *ordonnanceur) {
        arrete(current->actif);
        free(*ordonnanceur);
        *ordonnanceur = NULL;
    } else {
        *ordonnanceur = current->suivant;
        delete(current);
    }
}

void kill(process** ordonnanceur, int pid) {
  if (*ordonnanceur == NULL) return;
  process* current = (*ordonnanceur);
  // Un PID étant unique, on traite dès le départ le cas de l'ordonnanceur
  if (current->actif->pid == pid) {
    delete_current(ordonnanceur);
    return;
  }
  current = current->suivant;
  while (current != *ordonnanceur) {
      if (current->actif->pid == pid) {
          delete(current);
          return; // au lieu de break : de toute façon, on n'a rien d'autre à faire
      }
    current = current->suivant;
  }
}

void killall(process** ordonnanceur, char* exec) {
  if (*ordonnanceur == NULL) return;
  process* current = (*ordonnanceur)->suivant;
  while (current != *ordonnanceur) {
    process* next = current->suivant;
      if (strcmp(current->actif->exec, exec) == 0)
          delete(current);
      current = next;
  }

  if (strcmp(current->actif->exec, exec) == 0)
    delete_current(ordonnanceur);
}

void round_robin(process** ordonnanceur) {
  while (*ordonnanceur != NULL) {
    processus* actif = (*ordonnanceur)->actif;
    cpu_quantum(actif);
    if (est_fini(actif))
      delete_current(ordonnanceur);
    else
      *ordonnanceur = (*ordonnanceur)->suivant;
  }
}

int main(void) {

  srand(time(NULL));

  processus* emacs = lance_processus("emacs");
  arrete(emacs);

}
