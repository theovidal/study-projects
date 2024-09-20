#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define STBI_NO_FAILURE_STRINGS
#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STBI_FAILURE_USERMSG
#include "stb_image.h"
#include "stb_image_write.h"

#include "seam_carving.h"

double min(double a, double b) {
    return (a <= b) ? a : b;
}

image *image_load(char *filename){
    int w, h, channels;
    uint8_t *data = stbi_load(filename, &w, &h, &channels, 0);
    if (!data) {
        fprintf(stderr, "Erreur de lecture.\n");
        stbi_failure_reason();
        exit(EXIT_FAILURE);
    }
    if (channels != 1){
        fprintf(stdout, "Pas une image en niveaux de gris.\n");
        exit(EXIT_FAILURE);
    }
    image *im = image_new(h, w);
    for (int i = 0; i < h; i++){
        for (int j = 0; j < w; j++){
            im->at[i][j] = data[j + i * w];
        }
    }
    free(data);
    return im;
}

void image_save(image *im, char *filename){
    int h = im->h;
    int w = im->w;
    int stride_length = w;
    uint8_t *data = malloc(w * h * sizeof(uint8_t));
    for (int i = 0; i < h; i++){
        for (int j = 0; j < w; j++){
            data[j + i * w] = im->at[i][j];
        }
    }
    if (!stbi_write_png(filename, w, h, 1, data, stride_length)){
        fprintf(stderr, "Erreur d'écriture.\n");
        image_delete(im);
        free(data);
        exit(EXIT_FAILURE);
    }
    free(data);
}


image *image_new(int h, int w) {
    image* new = malloc(sizeof(image));
    new->h = h;
    new->w = w;
    new->at = malloc(h * sizeof(uint8_t*));
    for (int i = 0; i < h; i++) {
        new->at[i] = malloc(w * sizeof(uint8_t));
    }
    return new;
}

void image_delete(image *im) {
    for (int i = 0; i < im->h; i++) {
        free(im->at[i]);
    }
    free(im->at);
    free(im);
}

void invert(image *im) {
    for (int i = 0; i < im->h; i++) {
        for (int j = 0; j < im->w; j++) {
            im->at[i][j] = 255 - im->at[i][j];
        }
    }
}

void binarize(image *im) {
    for (int i = 0; i < im->h; i++) {
        for (int j = 0; j < im->w; j++) {
            im->at[i][j] = (im->at[i][j] < 128) ? 0 : 255;
        }
    }
}

void flip_horizontal(image *im) {
    for (int i = 0; i < im->h; i++) {
        for (int j = 0; j < im->w/2; j++) {
            uint8_t temp = im->at[i][j];
            im->at[i][j] = im->at[i][im->w - 1 - j];
            im->at[i][im->w - 1 - j] = temp;
        }
    }
}


energy *energy_new(int h, int w) {
    energy* en = malloc(sizeof(energy));
    en->h = h;
    en->w = w;
    en->at = malloc(h * sizeof(double*));
    for (int i = 0; i < h; i++) {
        en->at[i] = malloc(w * sizeof(double));
    }
    return en;
}

void energy_delete(energy *e) {
    for (int i = 0; i < e->h; i++) {
        free(e->at[i]);
    }
    free(e->at);
    free(e);
}

void compute_energy(image *im, energy *e) {
    for (int i = 0; i < im->h; i++) {
        for (int j = 0; j < im->w; j++) {
            int jr = j < im->w - 1 ? j + 1 : j; 
            int jl = j > 0 ? j - 1 : j;
            int ib = i < im->h - 1 ? i + 1 : i;
            int it = i > 0 ? i - 1 : i;

            uint8_t p_i_jr = im->at[i][jr];
            uint8_t p_i_jl = im->at[i][jl];
            uint8_t p_ib_j = im->at[ib][j];
            uint8_t p_it_j = im->at[it][j];

            e->at[i][j] =
                fabs((double)p_i_jr - (double)p_i_jl)/(double)(jr - jl)
              + fabs((double)p_ib_j - (double)p_it_j)/(double)(ib - it);
        }
    }
}

image *energy_to_image(energy *e) {
    image* im = image_new(e->h, e->w);
    double min = e->at[0][0];
    double max = e->at[0][0];
    // La valeur max de l'énergie sera blanche, sinon noire
    for (int i = 0; i < e->h; i++) {
        for (int j = 0; j < e->w; j++) {
            min = (e->at[i][j] < min) ? e->at[i][j] : min;
            max = (e->at[i][j] > max) ? e->at[i][j] : max;
        }
    }
    for (int i = 0; i < e->h; i++) {
        for (int j = 0; j < e->w; j++) {
            im->at[i][j] = (uint8_t)(e->at[i][j] - min) * 255 / (max - min);
        }
    }

    return im;
}



void remove_pixel(uint8_t *line, double *e, int w) {
    double e_min = e[0];
    int j_min = 0;
    for (int j = 0; j < w; j++) {
        if (e[j] < e_min) {
            e_min = e[j];
            j_min = j;
        }
    }
    for (int j = j_min; j < w - 1; j++) {
        line[j] = line[j + 1];
    }
}

void reduce_one_pixel(image *im, energy *e) {
    compute_energy(im, e);
    for (int i = 0; i < im->h; i++) {
        remove_pixel(im->at[i], e->at[i], im->w);
    }
    im->w--;
    e->w--;
}

void reduce_pixels(image *im, int n) {
    energy* e = energy_new(im->h, im->w);
    for (int i = 0; i < n; i++) {
        reduce_one_pixel(im, e);
    }
    energy_delete(e);
}
// Spoiler : cette technique c'est de la bouse!


int best_column(energy *e) {
    double e_min = 99999999999999999;
    int j_min = 0;
    for (int j = 0; j < e->w; j++) {
        double e_col = 0;
        for (int i = 0; i < e->h; i++) {
            e_col += e->at[i][j];
        }
        if (e_col < e_min) {
            e_min = e_col;
            j_min = j;
        }
    }
    return j_min;
}

void reduce_one_column(image *im, energy *e) {
    compute_energy(im, e);
    int j_min = best_column(e);
    for (int j = j_min; j < im->w - 1; j++) {
        for (int i = 0; i < im->h; i++) {
            im->at[i][j] = im->at[i][j+1];
        }
    }
    im->w--;
    e->w--;
}

void reduce_column(image *im, int n) {
    energy* e = energy_new(im->h, im->w);
    for (int k = 0; k < n; k++) {
        reduce_one_column(im, e);
    }
    energy_delete(e);
}

void energy_min_path(energy *e) {
    for (int i = 1; i < e->h; i++) {
        for (int j = 0; j < e->w; j++) {
            double jt = e->at[i - 1][j];
            double jr = (j == e->w - 1) ? jt : e->at[i - 1][j + 1];
            double jl = (j == 0) ? jt : e->at[i - 1][j - 1];
            e->at[i][j] += min(min(jr, jt), jl);
        }
    }
}

path *path_new(int n) {
    path* new = malloc(sizeof(path));
    new->size = n;
    new->at = malloc(n * sizeof(int));
    return new;
}

void path_delete(path *p) {
    free(p->at);
    free(p);
}

void compute_min_path(energy *e, path *p) {
    double e_min = e->at[e->h - 1][0];
    int j_min = 0;
    for (int j = 1; j < e->w; j++) {
        double v = e->at[e->h - 1][j];
        if (v < e_min) {
            e_min = v;
            j_min = j;
        }
    }

    p->at[e->h - 1] = j_min;
    int j = j_min;
    for (int i = e->h - 2; i >= 0; i--) {
        int jl = (j == 0) ? j : j - 1;
        int jr = (j == e->w - 1) ? j : j + 1;
        e_min = e->at[i][jl];
        j_min = jl;
        for (int jj = jl + 1; jj <= jr; jj++) {
            if (e->at[i][jj] < e_min) {
                e_min = e->at[i][jj];
                j_min = jj;
            }
        }
        p->at[i] = j_min;
        j = j_min;
    }
}

void reduce_seam_carving(image *im, int n) {
    energy* e = energy_new(im->h, im->w);
    path* p = path_new(e->h);
    for (int k = 0; k < n; k++) {
        compute_energy(im, e);
        energy_min_path(e);
        compute_min_path(e, p);
        for (int i = 0; i < p->size; i++) {
            for (int j = p->at[i]; j < im->w - 1; ++j) {
                im->at[i][j] = im->at[i][j + 1];
            }
        }
        im->w--;
        e->w--;
    }
    energy_delete(e);
    path_delete(p);
}


int main(void) {
    image* im = image_load("tp_29/images/bird.png");

    energy* en = energy_new(im->h, im->w);
    compute_energy(im, en);
    energy_min_path(en);
    image* res = energy_to_image(en);
    image_save(res, "tp_29/test.png");
    image_delete(res);
    energy_delete(en);

    flip_horizontal(im);
    reduce_seam_carving(im, 200);
    image_save(im, "tp_29/result.png");
    image_delete(im);
    return 0;
}
