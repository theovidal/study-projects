#ifndef LECTURE_H
#define LECTURE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

struct geopoint {
  double latitude, longitude ;
};

struct route {
  int depart, arrivee;
  double distance;
  char* nom;
};

extern struct route* routes;
extern int nb_routes ;
extern struct geopoint * position ;
extern int nb_positions;

void lit_routes(void) ;
void lit_positions(void) ;
void nettoie(void);

#endif
