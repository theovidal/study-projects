#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>

#define NBCOLORS 30

const int ITERMAX = 1000;

const int TAILLE = 1024;

const double XMIN = 0.00172;
const double XMAX = 0.00184;
const double YMIN = -0.82258;
const double YMAX = -0.82246;

struct Complexe {
    double re;
    double im;
};

typedef struct Complexe complexe;

typedef int rgb[3];

// const int key_values[6] = {0, 40, 100, 150, 200, 255};
const float key_values[6] = {0., 0.16, 0.42, 0.6425, 0.8575, 1.};

const rgb key_colors[6] = {
{0, 7, 100},
{32, 107, 203},
{237, 255, 255},
{255, 170, 0},
{0, 2, 0},
{0, 7, 100}
};

rgb palette[NBCOLORS];

void initialize_palette(void){
    int down = 0;
    for (int i = 0; i < NBCOLORS; ++i){
        float f = 1.f / NBCOLORS * i;
        if (f > key_values[down + 1]){
            down++;
        }
        const int *color_down = key_colors[down];
        const int *color_up = key_colors[down + 1];
        float ratio = (f - key_values[down]) / (key_values[down + 1] - key_values[down]);
        if (ratio < 0. || ratio > 1.){
            printf("i=%d f=%.3f ratio=%.3f\n", i, f, ratio);
            assert(false);
        }
        for (int j = 0; j < 3; ++j){
            palette[i][j] = color_down[j] + ratio * (color_up[j] - color_down[j]);
        }
    }
}

void get_color(rgb color, float iter){
    int down = (int)iter % NBCOLORS;
    int up = (down + 1) % NBCOLORS;
    float ratio = iter - floor(iter);
    for (int j = 0; j < 3; ++j){
        color[j] = palette[down][j] + ratio * (palette[up][j] - palette[down][j]);
    }
}

complexe mul(complexe a, complexe b){
    complexe c;
    c.re = a.re * b.re - a.im * b.im;
    c.im = a.re * b.im + a.im * b.re;
    return c;
}

complexe add(complexe a, complexe b){
    complexe c;
    c.re = a.re + b.re;
    c.im = a.im + b.im;
    return c;
}

complexe f(complexe zn, complexe c){
    return add(c, mul(zn, zn));
}

double module_carre(complexe z){
    return z.re * z.re + z.im * z.im;
}

bool diverge(complexe c){
    complexe z = {.re = 0., .im = 0.};
    for (int i = 0; i < ITERMAX; i++){
        if (module_carre(z) > 4.) {
            return true;
        }
        z = f(z, c);
    }
    return false;
}


int nb_iter(complexe c){
    complexe z = {.re = 0., .im = 0.};
    for (int i = 0; i < ITERMAX; i++){
        if (module_carre(z) > 4.) {
            return i;
        }
        z = f(z, c);
    }
    return 0;
}

float smoothed_iter(complexe c){
    complexe z = {.re = 0., .im = 0.};
    float iter = 0.;
    for (; iter < ITERMAX && module_carre(z) < (1 << 16); iter++){
        z = f(z, c);
    }
    if (iter < ITERMAX){
        float log2_zn = log2(module_carre(z)) / 2.;
        float nu = log2(log2_zn);
        iter = iter + 1 - nu;
    }
    return iter;
}



complexe affixe(int i, int j){
    complexe c;
    c.re = XMIN + i * (XMAX - XMIN) / TAILLE;
    c.im = YMIN + j * (YMAX - YMIN) / TAILLE;
    return c;
}

int main(void){
    initialize_palette();
    printf("P3\n");
    printf("%d %d\n", TAILLE, TAILLE);
    printf("255\n");
    for (int i = 0; i < TAILLE; ++i){
        for (int j = 0; j < TAILLE; ++j){
            int x = j;
            int y = TAILLE - i;
            complexe c = affixe(x, y);
            float iter = smoothed_iter(c);
            rgb color = {0, 0, 0};
            if (iter != ITERMAX){
                get_color(color, iter);
            }
            printf("%d %d %d ", color[0], color[1], color[2]);
        }
        printf("\n");
    }
}
