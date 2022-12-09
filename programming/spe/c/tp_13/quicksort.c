#define INSERTION_LIMIT 16

void swap(int *arr, int i, int j){
    int tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
}


void insertion_sort(int *arr, int len) {
    for (int i = 0; i < len; i++) {
        int x = arr[i];
        int j = i;
        while (j > 0 && arr[j - 1] > x) {
            arr[j] = arr[j - 1];
            j--;
        }
        arr[j] = x;
    }
}

int partition(int *arr, int len) {
    int i = 1;
    for (int j = 1; j < len; j++) {
        if (arr[j] <= arr[0]) {
            swap(arr, i, j);
            i++;
        }

    }
    // Prendre i - 1 : on est potentiellement arrivés à len !
    swap(arr, i - 1, 0);
    return i - 1;
}

void full_sort(int *arr, int len) {
    if (len < INSERTION_LIMIT) {
        insertion_sort(arr, len);
        return;
    }
    int i = partition(arr, len);
    full_sort(arr, i);
    // arr[i] est le pivot, par définition de l'algo il n'a pas besoin d'être trié...
    full_sort(&arr[i + 1], len - i - 1);
}
