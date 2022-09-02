#include <stdlib.h>
#include <math.h>
#include <stdio.h>

typedef struct v2D {
    float x;
    float y;
} v2D;

float norm(v2D* v) {
    return sqrt(pow(v->x, 2) + pow(v->y, 2));
}

// La fonction de comparaison est toujours void, il faut donc cast le type
int compare_norms(const void* x, const void* y) {
    v2D* vx = (v2D*)x;
    v2D* vy = (v2D*)y;
    return norm(vx) - norm(vy);
}

void sort_by_norm(v2D points[], int len) {
    qsort(points, len, sizeof(v2D), compare_norms);
}

int main(void) {
    v2D* t = malloc(5 * sizeof(v2D));
    t[0].x = 5;
    t[0].y = 0; // Bien définir les valeurs de y (et globalement tous les champs d'une struct),
    t[1].x = 4; // sinon ça peut être n'importe quoi qu'il y a dans cette case mémoire
    t[1].y = 0;
    t[2].x = 2;
    t[2].y = 0;
    t[3].x = 1;
    t[3].y = 0;
    t[4].x = 7;
    t[4].y = 0;
    sort_by_norm(t, 5);
    for (int i = 0; i < 5; i++) {
        printf("%.3f\n", t[i].x);
    }
    return 0;
}

