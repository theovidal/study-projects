#include <stdlib.h>
#include <stdio.h>

// même concept qu'en OCaml : on parcourt linéairement les deux parties,
// en prenant un élément d'une ou de l'autre en fonction de la situation.
// Ici on a besoin d'un stockage auxiliaire car on est mutable.
void merge(int arr[], int mid, int len, int buffer[]) {
    int i = 0;
    int j = mid;
    for (int k = 0; k < len; k++) {
        if (j >= len || arr[i] <= arr[j]) {
            buffer[k] = arr[i];
            i++;
        }
        else { // i >= mid || arr[i] > arr[j]
             buffer[k] = arr[j];
            j++;
        }
    }

    for (int k = 0; k < len; k++) {
        arr[k] = buffer[k];
    }
}

void merge_sort_aux(int arr[], int len, int buffer[]) {
    if (len < 2) return;
    int mid = len / 2;
    merge_sort_aux(arr, mid, buffer);
    merge_sort_aux(&arr[mid], len - mid, buffer);
    merge(arr, mid, len, buffer);
}

void merge_sort(int arr[], int len) {
    int* buffer = malloc(len * sizeof(int));
    merge_sort_aux(arr, len, buffer);
    free(buffer);
}

int main(void) {
    int arr[] = {2, 3, 4, 5, 1, 9, 10};
    int buffer[] = {0, 0, 0, 0, 0, 0, 0};
    merge(arr, 4, 7, buffer);
    for (int i = 0; i < 7; i++) {
        printf("%d ", arr[i]);
    }
    return 0;
}
