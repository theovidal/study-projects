
/********************************************************************/
/* Concours Centrale-Supélec                                        */
/* Sujet 0 - MPI                                                    */
/* https://www.concours-centrale-supelec.fr                         */
/* CC BY-NC-SA 3.0                                                  */
/********************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>

#define LONGUEUR_MAX 100

struct node_s {
  char* key;
  int val;
  struct node_s* left;
  struct node_s* right;
};
typedef struct node_s node;

int min(int a, int b) {
  if (a >= b) return b;
  else return a;
}

int max(int a, int b) {
  if (a >= b) return a;
  else return b;
}

int lexcmp(char* s1, char* s2) {
  int n1 = strlen(s1);
  int n2 = strlen(s2);
  int n = min(n1, n1);

  for (int i = 0; i < n; i++) {
    if (s1[i] < s2[i]) return -1;
    if (s1[i] > s2[i]) return 1;
  }
  if (n2 > n1) return -1;
  else return 0;
}

void print_bst_aux(node* bst, int p) {
  if (bst == NULL) {
    return;
  }
  print_bst_aux(bst->right, p + 1);
  for (int i = 0; i < p; i = i + 1) {
    printf("\t");
  }
  printf("%s : %d\n", bst->key, bst->val);
  print_bst_aux(bst->left, p + 1);
}

void print_bst(node* bst) {
  print_bst_aux(bst, 0);
}

node* delete_min(node* bst, node** min) {
  assert(bst != NULL);
  if (bst->left == NULL) {
    *min = bst;
    return bst->right;
  } else {
    bst->left = delete_min(bst->left, min);
    return bst;
  }
}

node* delete(char* key, node* bst) {
  if (bst == NULL) {
    return NULL;
  } else {
    int c = lexcmp(key, bst->key);
    if (c == 0) {
      node* new;
      if (bst->left == NULL) {
        new = bst->right;
      } else if (bst->right == NULL) {
        new = bst->left;
      } else {
        node* right = delete_min(bst->right, &new);
        new->right = right;
        new->left = bst->left;
      }
      free(bst->key);
      free(bst);
      bst = new;
    } else if (c < 0) {
      bst->left = delete(key, bst->left);
    } else {
      bst->right = delete(key, bst->right);
    }
    return bst;
  }
}

// -----------------------------------
// Fonctions jugées nécessaires :
// - augmentation de la valeur d'un élément 
//   (s'il n'existe pas, le créer et lui assigner alors 1)
// - recherche d'un élément
// - pour la libération de la mémoire : écriture du dictionnaire dans un fichier

// Est responsable de l'allocation de la mémoire
node* increase(node* t, char* key) {
  if (t == NULL) {
    node* new = malloc(sizeof(node));
    char* node_key = malloc((strlen(key) + 1) * sizeof(char));
    strcpy(node_key, key);
    new->key = node_key;
    new->val = 1;
    new->left = NULL; new->right = NULL;
    return new;
  }
  int comp = lexcmp(key, t->key);
  if (comp > 0) t->right = increase(t->right, key);
  else if (comp < 0) t->left = increase(t->left, key);
  else t->val++;

  return t;
}

node* new_tree(void) {
  return NULL;
}

// Si l'élément recherché n'est pas dans l'arbre, la fonction renvoie une valeur spéciale
// sachant que nous travaillons avec des occurences de mots (donc des entiers naturels),
// on renverra -1 si la recherche est infructueuse
int search(node* t, char* key) {
  if (t == NULL) return -1;
  int comp = lexcmp(t->key, key);
  if (comp > 0) return search(t->left, key);
  else if (comp < 0) return search(t->right, key);
  else return t->val;
}

// Opération destructice !!
// Destinée à être utilisée à la toute fin du procédé de comptage des occurences
int parse_tree(FILE* f, node* t, char* plus_frequent, int* nb_plus_frequent) {
  node* min;
  int nb_longueur_10 = 0;
  *nb_plus_frequent = 0;
  while (t != NULL) {
    t = delete_min(t, &min);
    fprintf(f, "%s %d\n", min->key, min->val);
    if (min->val == 10) nb_longueur_10++;
    if (min->val > *nb_plus_frequent) {
      strcpy(plus_frequent, min->key);
      *nb_plus_frequent = min->val;
    }
    free(min->key);
    free(min);
  }
  return nb_longueur_10;
}
// Question 6
void test_lexcmp() {
  char* mots1[] =  {"a", "aab", "acba", "ac", "aa"};
  char* mots2[] =  {"b", "aac", "abba", "a",  "aa"};
  int resultat[] = {-1,  -1,    1,      1,     0  };
  for (int i = 0; i < 5; i++) {
    assert(lexcmp(mots1[i], mots2[i]) == resultat[i]);
  }
  printf("Tests for lexcmp passed\n");
}
// Question 6
void test_arbres() {
  node* t = new_tree();

  // Ordre : a < aaab < ab < abaa < abba < bba
  char* mots[] =     {"abaa", "aaab", "ab", "a", "bba", "abba"};
  int occurences[] = {   4,     2,     6,    3,    4,     9   };
  for (int i = 0; i < 6; i++) {
    for (int k = 0; k < occurences[i]; k++) {
      t = increase(t, mots[i]);
    }
  }

  node* min;
  t = delete_min(t, &min);
  assert(lexcmp(min->key, "a") == 0);
  assert(min->val == 3);
  free(min->key);
  free(min);

  t = delete_min(t, &min);
  assert(lexcmp(min->key, "aaab") == 0);
  printf("%d\n", min->val);
  assert(min->val == 2);
  free(min->key);
  free(min);

  t = delete_min(t, &min); free(min->key); free(min);
  t = delete_min(t, &min); free(min->key); free(min);
  t = delete_min(t, &min); free(min->key); free(min);

  t = delete_min(t, &min);
  assert(lexcmp(min->key, "bba") == 0);
  assert(min->val == 4);
  free(min->key);
  free(min);

  printf("Test for tree passed\n");
}

// Question 7
node* make_lex(FILE* f, node* t) {
  while (true) {
    char* line = malloc(LONGUEUR_MAX * sizeof(char));
    if (fscanf(f, "%s", line) == EOF) {
      free(line);
      return t;
    }
    t = increase(t, line);
    free(line);
  }
  return t;
}

int hauteur(node* t) {
  if (t == NULL) return -1;
  return 1 + max(hauteur(t->right), hauteur(t->left));
}

// Question 7
int main(int argv, char* argc[]) {
  test_arbres();

  node* t = new_tree();
  FILE* in = stdin;
  FILE* out = stdout;
  if (argv > 1) {
    if (lexcmp(argc[1], "--help") == 0) {
      printf("Usage: program <input_file?> <output_file?>\nIf not given, input/output set to stdin/stdout.");
      return EXIT_SUCCESS;
    }
    in = fopen(argc[1], "r");
  }
  
  if (argv > 2) out = fopen(argc[2], "w");

  t = make_lex(in, t);
  printf("Hauteur de l'arbre : %d\n", hauteur(t));
  int nb_plus_frequent;
  char* plus_frequent = malloc(LONGUEUR_MAX * sizeof(char));
  int nb_10 = parse_tree(out, t, plus_frequent, &nb_plus_frequent);
  printf ("Nombre de mots de 10 occurences: %d\n", nb_10);
  printf("Mot le plus fréquent : %s (avec %d occurences)", plus_frequent, nb_plus_frequent);
  free(plus_frequent);

  if (argv > 1) fclose(in);
  if (argv > 2) fclose(out);

  return EXIT_SUCCESS;
}
