#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define HEIGHT 301
#define WIDTH 301

typedef int rgb[3];

rgb red = {255, 0, 0};
rgb green = {0, 255, 0};
rgb blue = {0, 0, 255};
rgb black = {0, 0, 0};
rgb white = {255, 255, 255};
rgb lightgray = {150, 150, 150};

rgb canvas[HEIGHT][WIDTH];

void put_pixel(int x, int y, rgb c){
    int i = HEIGHT - 1 - y;
    int j = x;
    if (i < 0 || i >= HEIGHT || j < 0 || j > WIDTH) return;
    for (int k = 0; k < 3; k++){
        canvas[i][j][k] = c[k];
    }
}

/***********************/
/* Création du fichier */
/***********************/

/* Exercice 1 */

void print_canvas(void){
    printf("P3\n");
    printf("%d %d\n", WIDTH, HEIGHT);
    printf("255\n");
    for (int i = 0; i < HEIGHT; i++){
        for (int j = 0; j < WIDTH; j++){
            for (int k = 0; k < 3; k++){
                printf("%d ", canvas[i][j][k]);
            }
            printf("\n");
        }
    }
}

void write_canvas(char filename[]) {
    FILE *fptr;
    fptr = fopen(filename, "w");

    fprintf(fptr, "P3\n");
    fprintf(fptr, "%d %d\n", WIDTH, HEIGHT);
    fprintf(fptr, "255\n");
    for (int i = 0; i < HEIGHT; i++){
        for (int j = 0; j < WIDTH; j++){
            for (int k = 0; k < 3; k++){
                fprintf(fptr, "%d ", canvas[i][j][k]);
            }
            fprintf(fptr, "\n");
        }
    }

    fclose(fptr);
    memset(canvas, 0, sizeof(canvas));
}

/***********************/
/*  Primitives simples */
/***********************/

/* Exercice 3 */

void draw_h_line(int y, int x0, int x1, rgb c) {
    for (int i = x0; i <= x1; i++) {
        put_pixel(i, y, c);
    }
}

void draw_v_line(int x, int y0, int y1, rgb c) {
    for (int i = y0; i <= y1; i++) {
        put_pixel(x, i, c);
    }
}


/* Exercice 4 */

void draw_rectangle(int x_min, int y_min, int x_max, int y_max, rgb c) {
    draw_h_line(y_min, x_min, x_max, c);
    draw_h_line(y_max, x_min, x_max, c);
    draw_v_line(x_min, y_min, y_max, c);
    draw_v_line(x_max, y_min, y_max, c);
}

void fill_rectangle(int x_min, int y_min, int x_max, int y_max, rgb c) {
    for (int i = x_min; i <= x_max; i++) {
        draw_v_line(i, y_min, y_max, c);
    }
}


/* Exercice 5 */

void fill_disk(int xc, int yc, int radius, rgb c) {
    for (int w = xc - radius; w <= xc + radius; w++) {
        for (int h = yc - radius; h <= yc + radius; h++) {
            double distance = sqrt(pow(w - xc, 2) + pow(h - yc, 2));
            if (distance <= radius) {
                put_pixel(w, h, c);
            }
        }
    }
}



/***********************/
/* Mélange de couleurs */
/***********************/

/* Exercice 6 */

int clamp(double x) {
    if (x < 0) return 0;
    else if (x > 255) return 255;
    else return x;
}

void mix(rgb c0, rgb c1, double alpha, double beta, rgb result) {
    result[0] = clamp(c0[0] * alpha + c1[0] * beta);
    result[1] = clamp(c0[1] * alpha + c1[1] * beta);
    result[2] = clamp(c0[2] * alpha + c1[2] * beta);
}


/* Exercice 7 */

void draw_h_gradient(int y, int x0, int x1, rgb c0, rgb c1) {
    for (int i = x0; i <= x1; i++) {
        // alpha = 1 et beta = 0 sur x0, beta = 1 et alpha = 0 sur x1
        // (couleurs pleines aux extrémités)
        // Puis on divise par la longueur de la ligne pour faire varier entre 0 et 1
        double alpha = (x1 - i) * 1.0 / (x1 - x0);

        //double beta = (i - x0) * 1.0 / (x1 - x0);
        double beta = 1 - alpha; // plus efficace : on prend le complémentaire

        rgb color = {0, 0, 0};
        mix(c0, c1, alpha, beta, color);
        put_pixel(i, y, color);
    }
}

void fill_disk_gradient(int xc, int yc, int radius, rgb c_center, rgb c_edge) {
    for (int w = xc - radius; w <= xc + radius; w++) {
        for (int h = yc - radius; h <= yc + radius; h++) {
            double distance = sqrt(pow(w - xc, 2) + pow(h - yc, 2));
            if (distance <= radius) {
                double beta = distance / radius;
                double alpha = 1 - beta;
                rgb color = {0, 0, 0};
                mix(c_center, c_edge, alpha, beta, color);
                put_pixel(w, h, color);
            }
        }
    }
}


/* Exercice 8 */

void get_pixel(int x, int y, rgb result) {
    if (x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT) return;
    // Pas de = avec les tableaux, ça copiera le pointeur
    result[0] = canvas[HEIGHT - 1 - y][x][0]; // put_pixel mets les y de l'autre côté
    result[1] = canvas[HEIGHT - 1 - y][x][1]; // pour la cohérence avec le repère
    result[2] = canvas[HEIGHT - 1 - y][x][2]; // -> il faut partir dans l'autre sens
}

void mix_pixel(int x, int y, double alpha, double beta, rgb c1) {
    rgb c2;
    get_pixel(x, y, c2);

    rgb result;
    mix(c1, c2, alpha, beta, result);
    put_pixel(x, y, result);
}

void add_disk(int xc, int yc, int radius, rgb c) {
    for (int w = xc - radius; w <= xc + radius; w++) {
        for (int h = yc - radius; h <= yc + radius; h++) {
            double distance = sqrt(pow(w - xc, 2) + pow(h - yc, 2));
            if (distance <= radius) {
                mix_pixel(w, h, 1, 1, c);
            }
        }
    }
}



/*******************/
/* Tracé de lignes */
/*******************/

/* Exercice 9 */

// Traiter séparément les cas de pente <1 et >1
void draw_line(int x0, int y0, int x1, int y1, rgb c) {
    double m = 1.0 * (y1 - y0)/(x1 - x0);

    if (y0 == y1) draw_h_line(y0, x0, x1, c);
    if (x0 == x1) draw_v_line(x0, y0, y1, c);

    // Pente supérieure à 1 : on fait la ligne en faisant varier y
    // (sinon, il n'y a qu'un pixel par coordonnée horizontale)
    if (abs(y1 - y0) > abs(x1 - x0)) {
        if (y0 > y1) draw_line(x1, y1, x0, y0, c); // Inverser les points pour aller "de gauche à droite"
        for (int y = y0; y < y1; y++) {
            int x = round(x0 + (y - y0) / m);
            put_pixel(x, y, c);
        }
    } else {
        if (x0 > x1) draw_line(x1, y1, x0, y0, c);
        for (int x = x0; x < x1; x++) {
            int y = round(y0 + m * (x - x0));
            put_pixel(x, y, c);
        }   
    }
}


/* Exercice 10 */

void draw_spokes(int xc, int yc, int radius, int nb_spokes, rgb c) {
    double angle = 2 * M_PI / nb_spokes;
    for (int i = 0; i < nb_spokes; i++) {
        draw_line(xc, yc, xc + cos(i * angle) * radius, yc + sin(i * angle) * radius, c);
    }
}


/* Exercice 11 */

void bresenham_low(int x0, int y0, int x1, int y1, rgb c);

void bresenham_high(int x0, int y0, int x1, int y1, rgb c);

void bresenham(int x0, int y0, int x1, int y1, rgb c);


/* Exercice 12 */

void _draw_circle_points(int xc, int yc, int dx, int dy, rgb c) {
    put_pixel(xc + dx, yc + dy, c);
    put_pixel(xc - dx, yc + dy, c);
    put_pixel(xc + dx, yc - dy, c);
    put_pixel(xc - dx, yc - dy, c);
    put_pixel(xc + dy, yc + dx, c);
    put_pixel(xc - dy, yc + dx, c);
    put_pixel(xc + dy, yc - dx, c);
    put_pixel(xc - dy, yc - dx, c);
}

void draw_circle(int xc, int yc, int radius, rgb c) {
    int dx = radius;
    int dy = 0;
    _draw_circle_points(xc, yc, dx, dy, c);
    while (dx > dy) {
        dy++;
        // Prendre le carré de la distance (on le compare avec le carré du rayon)
        int distance_top = dx * dx + dy * dy;
        int distance_diag = (dx - 1) * (dx - 1) + dy * dy;

        int ecart_top = abs(radius * radius - distance_top);
        int ecart_diag = abs(radius * radius - distance_diag);
        if (ecart_top > ecart_diag) {
            dx--;
        }
        _draw_circle_points(xc, yc, dx, dy, c);
    }
}


/*****************/
/* Fonction main */
/*****************/

int main(void){
    fill_disk_gradient(150, 150, 150, red, white);
    draw_spokes(150, 150, 150, 72, black);
    write_canvas("tp_13/results/spokes.ppm");

    add_disk(120, 140, 50, red);
    add_disk(180, 140, 50, green);
    add_disk(150, 190, 50, blue);
    write_canvas("tp_13/results/blend.ppm");

    for (int i = 120; i < 140; i++) {
        draw_circle(150, 150, i, red);
    }
    
    write_canvas("tp_13/results/circles.ppm");
}
