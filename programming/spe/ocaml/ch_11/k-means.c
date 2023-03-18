#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct Point {
    float x;
    float y;
} point;

float d2(point p, point q) {
    return pow(p.x - q.x, 2) + pow(p.y - q.y, 2);
}

void swap(point* data, int i, int j) {
    point temp = data[i];
    data[i] = data[j];
    data[j] = temp;
}

/* Première étape : choisir k points aléatoirement */
/* algorithme classique, utilisé pour le mélange de tableaux */
/* on swap chaque élément depuis la gauche avec un autre aléatoire, */
/* les k premiers éléments du tableau seront donc les centres choisis uniformément */
point* random_choice(point* data, int len, int k) {
    point* choices = malloc(k * sizeof(point));
    // indexes sert alors de pile : on empile quand on swap, on dépile pour annuler
    int* indexes = malloc(k * sizeof(int));
    for (int i = 0; i < k; i++) {
        indexes[i] = random() % (len - i);
        swap(data, i, indexes[i]);
        choices[i] = data[indexes[i]];
    }
    for (int i = k - 1; i >= 0; i--) {
        swap(data, i, indexes[i]);
    }
    free(indexes);
    return choices;
}

/* Donne le centre le plus proche du point p */
int nearest(point p, point centers[], int k) {
    int dmin = d2(centers[0], p);
    int imin = 0;
    for (int i = 1; i < k; i++) {
        float d = d2(centers[i], p);
        if (d < dmin) {
            imin = i;
            dmin = d;
        }
    }
    return imin;
}

/* Met à jour les centres affectés aux points */
bool update_assignment(point data[], point centers[], int assignment[], int n, int k) {
    bool has_changed = false;
    for (int i = 0; i < n; i++) {
        int n = nearest(data[i], centers, k);
        if (n != assignment[i]) {
            has_changed = true;
            assignment[i] = n;
        }
    }
    return has_changed;
}

/* Remplace les centres par l'isobarycentre des points qui leur sont affecté */
void update_centers(point data[], point centers[], int assignment[], int n, int k) {
    int* nb_points = malloc(k * sizeof(int));
    // On réinitialise les centres pour calculer le barycentre directement dedans
    for (int c = 0; c < k; c++) {
        centers[c].x = 0.;
        centers[c].y = 0.;
        nb_points[c] = 0;
    }
    for (int i = 0; i < n; i++) {
        int c = assignment[i];
        nb_points[c]++;
        centers[c].x += data[i].x;
        centers[c].y += data[i].y;
    }
    for (int c = 0; c < k; c++) {
        // S'il n'y a aucun point, de toute façon x et y vaudront 0
        // Il faut juste se prémunir de la division par zéro
        if (nb_points[c] == 0) continue;
        centers[c].x /= nb_points[c];
        centers[c].y /= nb_points[c];
    }
    free(nb_points);
}

int* kmeans(point data[], int n, int k, int itermax) {
    point* centers = random_choice(data, n, k);
    int* assignment = malloc(k * sizeof(int));
    for (int i = 0; i < k; i++) {
        assignment[i] = -1;
    }
    int iter = 0;
    while (iter < itermax && update_assignment(data, centers, assignment, n, k)) {
        update_centers(data, centers, assignment, n, k);
        iter++;
    }
    free(centers);
    return assignment;
}

point* load(FILE* input, int* n) {
    fscanf(input, "%d", n);
    point* data = malloc(*n * sizeof(point));
    for (int i = 0; i < *n; i++) {
        float x;
        float y;
        fscanf(input, "%f %f", &x, &y);
        data[i].x = x;
        data[i].y = y;
    }
    return data;
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("USAGE: kmeans [k] [itermax] [input_file?] [output_file?]\n");
        return 0;
    }
    int k = atoi(argv[1]);
    int itermax = atoi(argv[3]);

    FILE* input;
    if (argc > 3) input = fopen(argv[3], "r");
    else input = stdin;

    FILE* output;
    if (argc > 4) output = fopen(argv[4], "w");
    else output = stdout;

    int n;
    point* data = load(input, &n); 
    int* assignment = kmeans(data, n, k, itermax);

    for (int i = 0; i < n; i++) {
        fprintf(output, "%d ", assignment[i]);
    }

    fclose(input);
    fclose(output);
    free(data);
    free(assignment);
    return 0;
}
