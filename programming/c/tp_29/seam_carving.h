#ifndef SEAM_CARVING_H
#define SEAM_CARVING_H

#include <stdint.h>

struct image {
    uint8_t **at;
    int h;
    int w;
};

typedef struct image image;

image *image_new(int h, int w);
void image_delete(image *im);

image *image_load(char *filename);
void image_save(image *im, char *filename);

void invert(image *im);
void binarize(image *im);
void flip_horizontal(image *im);





struct energy {
    double **at;
    int h;
    int w;
};

typedef struct energy energy;

energy *energy_new(int h, int w);
void energy_delete(energy *en);

void compute_energy(image *im, energy *en);
image *energy_to_image(energy *en);
void remove_pixel(uint8_t *line, double *en, int w);
void reduce_one_pixel(image *im, energy *en);
void reduce_pixel(image *im, int n);
int best_column(energy *en);
void reduce_one_column(image *im, energy *en);
void reduce_column(image *im, int n);



void energy_min_path(energy *en);

struct path {
    int *at;
    int size;
};

typedef struct path path;

path *path_new(int n);
void path_delete(path *p);
void compute_min_path(energy *en, path *p);
void reduce_seam_carving(image *im, int n);



#endif //SEAM_CARVING_H
