#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>

const uint64_t FNV_OFFSET = 14695981039346656037ULL;
const uint64_t FNV_PRIME = 1099511628211ULL;

struct table {
  int capacite;
  int longueur;
  char **clefs;
};

/** renvoie la valeur de FNV-1a sur clef
 * clef : chaîne de caractères
 */
uint64_t hash_key(char *clef){
  uint64_t hash = FNV_OFFSET;
  int i = 0;

  while(clef[i] != '\0'){
    hash = hash ^ (uint64_t) clef[i]; // et bit à bit 
    hash = hash * FNV_PRIME;
    i = i + 1;
  }
  return hash;
}

struct table creation(int capacite) {
  char** clefs = malloc(capacite * sizeof(char*));
  assert(clefs != NULL);
  for (int i = 0; i < capacite; i++) {
    clefs[i] = NULL;
  }
  struct table t;
  t.capacite = capacite;
  t.longueur = 0;
  t.clefs = clefs;

  return t;
}

void sondage_lineaire(char** tab, char* clef, int capacite) {
  int indice = hash_key(clef) % capacite;
  int i = indice;
  while (tab[i] != NULL) i = (i + 1) % capacite;

  tab[i] = clef;
}

// Hypothèse : la table de hachage n'est jamais pleine
void insertion(struct table* t, char* clef) {
  sondage_lineaire(t->clefs, clef, t->capacite);
  t->longueur++;

  // Agrandit le tableau si le facteur de charge est supérieur à un demi
  if (2 * t->longueur >= t->capacite) {
    char** nouveau = malloc(t->capacite * 2 * sizeof(char*));
    assert(nouveau != NULL);
    for (int i = 0; i < t->capacite; i++) {
      if (t->clefs[i] != NULL) sondage_lineaire(nouveau, t->clefs[i], t->capacite * 2);
    }

    t->capacite *= 2;

    free(t->clefs);
    t->clefs = nouveau;
  }
}

bool apparait(struct table t, char* clef) {
  int indice = hash_key(clef) % t.capacite;
  int i = indice;
  while (t.clefs[i] != NULL && t.clefs[i] != clef) i = (i + 1) % t.capacite;
  return t.clefs[i] != NULL;
}

void suppression(struct table* t, char* clef) {
  int indice = hash_key(clef) % t->capacite;
  int i = indice;
  while (t->clefs[i] != NULL && t->clefs[i] != clef) i = (i + 1) % t->capacite;
  if (t->clefs[i] == NULL) fprintf(stderr, "Element %s is not present in the hash table", clef);
  else t->clefs[i] = "\0";
  t->longueur--;
}
