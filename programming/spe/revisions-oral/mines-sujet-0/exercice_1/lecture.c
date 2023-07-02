#include <stdbool.h>
#include "lecture.h"

int nb_positions;
struct geopoint * position ;
int nb_routes ;
struct route* routes;

void lit_routes() {
  FILE * fp = fopen ("routes.txt", "r"); // ouvre le fichier routes.txt en lecture

  
  fscanf(fp,"%d",&nb_routes); // lit la première ligne
  // qui donne le nombre de lignes dans le fichier
  routes = malloc(nb_routes * sizeof(struct route));
  for(int id_route = 0 ; id_route < nb_routes ; id_route++ ) {  // itère pour chaque ligne
    int depart, arrivee;
    double distance ;
    char nomRoute[270];
    fscanf(fp,"%d %d %lf  %[^\n]\n",&depart,&arrivee,&distance,nomRoute);

    routes[id_route].depart = depart;
    routes[id_route].arrivee = arrivee;
    routes[id_route].distance = distance;
    routes[id_route].nom = nomRoute;

  }
  fclose(fp);
}

void lit_positions() {
  FILE * fp = fopen ("positions.txt", "r");

  fscanf(fp, "%d", &nb_positions);
  position = malloc(nb_positions * sizeof(struct geopoint));
  for (int i = 0; i < nb_positions; i++) {
    double longitude, latitude;
    fscanf(fp,"%lf %lf\n", &longitude, &latitude);
    position[i].longitude = longitude;
    position[i].latitude = latitude;
  }
  fclose(fp);
}

void nettoie() {
  free(position);
  free(routes);
}
