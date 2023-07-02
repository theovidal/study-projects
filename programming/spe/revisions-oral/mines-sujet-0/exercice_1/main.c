#include <math.h>
#include "lecture.h"
//#include "liste.h"

struct chainee {
  int valeur;
  struct chainee* next;
};
typedef struct chainee chainee;

chainee* cons(int x, chainee* m) {
  chainee* nv = malloc(sizeof(chainee));
  nv->valeur = x;
  nv->next = m;
  return nv;
}

void detruit_chainee(chainee* m) {
  if (m != NULL) {
    detruit_chainee(m->next);
    free(m);
  }
}

const double DEGREE_VERS_RADIAN = M_PI / 180 ;
const double DIAMETRE_TERRE_EN_KM = 12742 ;

double max(double a, double b) {
  if (a >= b) return a;
  else return b;
}

double ll_distance(struct geopoint p1, struct geopoint p2) {
  return 
    DIAMETRE_TERRE_EN_KM * 1000 * asin(sqrt(
      pow(sin(DEGREE_VERS_RADIAN * (p1.latitude - p2.latitude)/2), 2)
      + cos(DEGREE_VERS_RADIAN * p1.latitude) * cos(DEGREE_VERS_RADIAN * p2.latitude) * 
        pow(sin(DEGREE_VERS_RADIAN * (p1.longitude - p2.longitude)/2), 2)));
}

void longueurs(double *longueur_moyenne, double* longueur_max) {
  *longueur_moyenne = 0;
  *longueur_max = 0;
  for (int i = 0; i < nb_routes; i++) {
    double longueur = ll_distance(position[routes[i].depart], position[routes[i].arrivee]);
    *longueur_max = max(*longueur_max, longueur);
    *longueur_moyenne += longueur;
  }
  if (nb_routes > 0) *longueur_moyenne /= nb_routes;
}

void sauvegarde_graphe() {
  chainee** g = malloc(nb_positions * sizeof(chainee));
  int* nb_voisins = malloc(nb_positions * sizeof(int));
  for (int i = 0; i < nb_positions; i++) {
    nb_voisins[i] = 0;
    g[i] = NULL;
  }

  for (int i = 0; i < nb_routes; i++) {
    int depart = routes[i].depart;
    int arrivee = routes[i].arrivee;
    g[depart] = cons(arrivee, g[depart]);
    g[arrivee] = cons(depart, g[arrivee]);
    nb_voisins[depart]++;
    nb_voisins[arrivee]++;
  }
  FILE * fp = fopen ("graphe.txt", "w");
  fprintf(fp, "%d\n", nb_positions);
  for (int i = 0; i < nb_positions; i++) {
    fprintf(fp, "%d ", nb_voisins[i]);
    chainee* u = g[i];
    while (u != NULL) {
      int k = u->valeur;
      double dist = ll_distance(position[i], position[k]);
      fprintf(fp, "%d %lf ", k, dist);
      u = u->next;
    }
    fprintf(fp, "\n");
    detruit_chainee(g[i]);
  }
  free(g);
  free(nb_voisins);
  fclose(fp);
}

int main() {
  lit_positions();
  lit_routes();

  //double longueur_moyenne, longueur_max;
  //longueurs(&longueur_moyenne, &longueur_max);

  sauvegarde_graphe();

  nettoie();
  return 0;
}
