#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

int n = 10000000;
int p = 3;
int nb_fils = 3;

void* f(void* arg) {
    int index = *(int*)arg;
    printf("Le fil %d a démarré\n", index);
    for (int i = 0; i < n * p; i++) {
        if (i % n == 0) {
            printf("Le fil %d a atteint %d\n", index, i);
        }
    }
    return NULL;
}

int main(void) {
    printf("Avant\n");
    pthread_t* fils = malloc(nb_fils * sizeof(pthread_t));
    int* args = malloc(nb_fils * sizeof(int));
    for (int i = 0; i < 3; i++) {
        args[i] = i;
        pthread_create(&fils[i], NULL, f, &args[i]);
    }
    printf("Pendant\n");
    for (int i = 0; i < 3; i++) {
        pthread_join(fils[i], NULL);
    }
    printf("Après\n");
    free(fils);
}
