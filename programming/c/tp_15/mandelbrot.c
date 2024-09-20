#include <stdio.h>

#define ROWS 6000
#define COLS 6000

int arr[ROWS][COLS];

int divergence(double xc, double yc, int itermax) {
    double xz = 0;
    double yz = 0;
    for (int i = 1; i <= itermax; i++) {
        double temp = xz * xz - yz * yz + xc;
        yz = 2 * xz * yz + yc;
        xz = temp;
        if (xz * xz + yz * yz > 4) return i;
    }
    return itermax + 1;
}

// On rajoute xmin et ymin pour les cas où j = 0 / i = 0
double re(int j, double xmin, double xmax) {
    return xmin + j * (xmax - xmin) / COLS;
}

// Le tableau est flip par rapport au plan complexe, d'où le ROWS - ...
double im(int i, double ymin, double ymax) {
    return ymin + (ROWS - i) * (ymax - ymin) / ROWS;
}

void fill_tab(double xmin, double xmax, double ymin, double ymax, int itermax) {
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            double xc = re(j, xmin, xmax);
            double yc = im(i, ymin, ymax);
            arr[i][j] = divergence(xc, yc, itermax);
        }
    }
}

void print_pixel_bw(int i, int j, int itermax) {
    if (arr[i][j] > itermax) printf("255 255 255\n");
    else printf("0 0 0\n");
}

void print_pixel_gs(int i, int j, int itermax) {
    int c = 255 * arr[i][j] / itermax;
    printf("%d %d %d\n", c, c, c);
}

void print_canvas(int itermax){
    printf("P3\n");
    printf("%d %d\n", ROWS, COLS);
    printf("255\n");
    for (int i = 0; i < ROWS; i++){
        for (int j = 0; j < COLS; j++){
            print_pixel_gs(i, j, itermax);
        }
    }
}

int main(void) {
    fill_tab(0.00172, 0.00184, -0.82258, -0.82246, 100);
    print_canvas(100);
}
