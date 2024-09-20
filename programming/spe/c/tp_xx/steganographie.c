#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

struct image {
  int larg;
  int haut;
  int maxc;
  uint16_t **pixels;
};

typedef struct image image;

/** Fabrique une image à partir du contenu d'un fichier supposé au
    format PGM ASCII */
image *charger_image(char *nom_fichier) {
  FILE* f = fopen(nom_fichier, "r");
  if (f == NULL) return NULL;

  image* img = malloc(sizeof(image));
  fscanf(f, "P2\n %d %d\n %d", &img->larg, &img->haut, &img->maxc);
  printf("%d %d\n", img->larg, img->haut);
  img->pixels = malloc(img->haut * sizeof(uint16_t*));
  for (int i = 0; i < img->haut; i++) {
    img->pixels[i] = malloc(img->larg * sizeof(uint16_t));
    for (int j = 0; j < img->larg; i++) {
      int pixel;
      fscanf(f, "%d", &pixel);
      img->pixels[i][j] = (uint16_t)(pixel);
    }
  }
  fclose(f);
  return img;
}

/** Libère une image */
void liberer_image(image *img) {
  for (int i = 0; i < img->haut; i++) {
    free(img->pixels[i]);
  }
  free(img->pixels);
  free(img);
}

/** Renvoie le caractère caché dans les `8` premières cases d'un
    tableau supposé de longueur au moins `8` */
char caractere(uint16_t *tab) {
  int c = 0;
  for (int i = 0; i < 8; i++) {
    c += (tab[i] & 1) << (8 - i);
  }
  return c;
}

/** Écrit dans le flux le message caché dans l'image. On suppose que
    l'image, et le flux sont valides, et en particulier non `NULL`. On
    suppose également que le message est valide et donc, en
    particuler, que `img->larg >= 8`. */
int sauvegarder_message(image *img, char *nom_sortie) {
  FILE* f = fopen(nom_sortie, "w");
  if (f == NULL) return 0;
  int i = 0;
  while (1) {
    char c = caractere(img->pixels[i]);
    if (c == '\0') break;
    fprintf(f, "%c", c);
  }
  return 1;
}

/** Insère le caractère dans les `8` premières cases du tableau. On
    suppose que le tableau est de taille suffisante. */
void inserer_caractere(char c, uint16_t *tab) {
}

/** Cache un message dans une image. On suppose que l'image est de
    hauteur et de largeur suffisante. */
int cacher(image *img, char *nom_entree) {
  return 1;
}

/** Sauvegarde une image dans un fichier au format PGM ASCII. On
    suppose que l'image est valide. */
int sauvegarder_image(image *img, char *nom_fichier) {
  return 1;
}

int main(int argc, char* argv[]) {
  if (argc < 3) {
    printf("Il faut passer un nom de fichier d'entrée et de sortie");
    return 0;
  }
  image* img = charger_image(argv[1]);
  sauvegarder_message(img, argv[2]);
  liberer_image(img);
}
