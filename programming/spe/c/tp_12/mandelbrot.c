#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <stdint.h>

#include "clock.h"

#define ROWS 4000
#define COLS 4000
#define NB_THREADS 8000

uint8_t arr[ROWS][COLS];

int ITERMAX;
double XMIN, XMAX, YMIN, YMAX;

typedef struct range {
    int imin;
    int imax;
} range;

int divergence(double xc, double yc){
    double x = 0.;
    double y = 0.;
    int i = 0;
    while (x*x + y*y <= 4. && i <= ITERMAX){
        double tmp = x;
        x = x*x - y*y + xc;
        y = 2. * tmp * y + yc;
        i++;
    }
    return i;
}

double re(int j){
    double ratio = (double)j / (COLS - 1);
    return XMIN + ratio * (XMAX - XMIN);
}

double im(int i){
    double ratio = (double)i / (ROWS - 1);
    return YMAX + ratio * (YMIN - YMAX);
}

void* fill_tab(void* args) {
    range r = *(range*)args;
    for (int i = r.imin; i < r.imax; i++) {
        for (int j = 0; j < COLS; j++) {
            double xc = re(j);
            double yc = im(i);
            divergence(xc, yc);
        }
    }
    return NULL;
}

void thread_fill_tab(){
    pthread_t threads[NB_THREADS];
    range args[NB_THREADS];
    for (int i = 0; i < NB_THREADS; i++){
        args[i].imin = i * ROWS/NB_THREADS;
        args[i].imax = (i+1) * ROWS/NB_THREADS;
        pthread_create(&threads[i], NULL, fill_tab, &args[i]);
    }
    for (int i = 0; i < NB_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }
}



void print_pixel_gs(int i, int j){
    int c = 255 * arr[i][j] / ITERMAX;
    for (int k = 0; k < 3; k++){
        printf("%d ", c);
    }
    printf("\n");
}

void print_tab(void){
    printf("P3\n");
    printf("%d %d\n", COLS, ROWS);
    printf("255\n");
    for (int i = 0; i < ROWS; i++){
        for (int j = 0; j < COLS; j++){
            print_pixel_gs(i, j);
        }
    }
}


int main(int argc, char* argv[]){
    XMIN = -2.;
    XMAX = 2.;
    YMIN = -2.;
    YMAX = 2.;
    ITERMAX = 20;
    if (argc >= 2) {
        ITERMAX = atoi(argv[1]);
    }
    if (argc == 6){
        XMIN = atof(argv[2]);
        XMAX = atof(argv[3]);
        YMIN = atof(argv[4]);
        YMAX = atof(argv[5]);
    }
    timestamp t0 = gettime();
    thread_fill_tab();
    timestamp t1 = gettime();
    fprintf(stderr, "Time : %.3fs\n", delta_t(t0, t1));
    return 0;
}
