#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>

void print_array(int *t, int n){
    for (int i = 0; i < n; i++){
        printf("%d ", t[i]);
    }
    printf("\n");
}

int *range(int a, int b){
    assert(b >= a);
    int *t = malloc((b - a) * sizeof(int));
    for (int i = 0; i < b - a; i++) {
        t[i] = a + i;
    }
    return t;
}

int *random_array(int len, int bound){
    int *arr = malloc(len * sizeof(int));
    for (int i = 0; i < len; i++){
        arr[i] = rand() / bound;
    }
    return arr;
}

int *copy(int *arr, int len){
    int *arr_copy = malloc(len * sizeof(int));
    memcpy(arr_copy, arr, len * sizeof(int));
    return arr_copy;
}

bool is_sorted(int *t, int len){
    for (int i = 1; i < len; i++){
        if (t[i] < t[i - 1]) return false;
    }
    return true;
}

bool is_equal(int *arr1, int *arr2, int len){
    for (int i = 0; i < len; i++) {
        if (arr1[i] != arr2[i]) return false;
    }
    return true;
}



void insertion_sort(int *arr, int len){
    for (int i = 1; i < len; i++){
        int j = i;
        int x = arr[i];
        while (j > 0 && x < arr[j - 1]) {
            arr[j] = arr[j - 1];
            j--;
        }
        arr[j] = x;
    }
}

void swap(int *t, int i, int j){
    int x = t[i];
    t[i] = t[j];
    t[j] = x;
}


int partition(int* arr, int len) {
    int piv = arr[0];
    int i = 1;
    for (int j = 1; j < len; j++) {
        if (arr[j] <= piv) {
            swap(arr, i, j);
            i++;
        }
    }
    swap(arr, 0, i - 1);
    return i - 1;
}

void quicksort(int* arr, int len) {
    if (len < 2) return;

    int k = partition(arr, len);
    quicksort(arr, k);
    quicksort(&arr[k + 1], len - k - 1);
}

void test_quicksort() {
    for (int i = 0; i < 10; i++) {
        int* arr = random_array(100, 10000000);
        quicksort(arr, 100);
        assert(is_sorted(arr, 100));
        free(arr);
    }
    printf("quicksort: ok!");
}


int quickselect_aux(int* arr, int k, int len) {
    assert(len > 0);
    if (len == 1) return arr[0];

    int piv = partition(arr, len);
    if (piv == k) return arr[piv];
    if (piv > k) return quickselect_aux(arr, k, piv);
    return quickselect_aux(&arr[piv + 1], k - piv - 1, len - piv - 1);
}

int quickselect(int* arr, int k, int len) {
    int* cp = copy(arr, len);
    int el = quickselect_aux(arr, k, len);
    free(cp);
    return el;
}

void test_quickselect() {
    for (int i = 0; i < 10; i++) {
        int* arr = random_array(100, 10000000);
        int el = quickselect(arr, 10, 100);
        quicksort(arr, 100);
        assert(arr[10] == el);
        free(arr);
    }
    printf("quickselect: ok!");
}


int left(int i) {
    return 2 * i + 1;
}
int right(int i) {
    return 2 * i + 2;
}

void siftdown(int* t, int n, int i) {
    int imax = i;
    if (left(i) < n && t[imax] < t[left(i)]) imax = left(i);
    if (right(i) < n && t[imax] < t[right(i)]) imax = right(i);

    if (imax != i) {
        swap(t, i, imax);
        siftdown(t, n, imax);
    }
}

void heapify(int* t, int n) {
    for (int i = (n - 1)/2; i >= 0; i--) {
        siftdown(t, n, i);
    }
}

void heapsort(int* arr, int len) {
    heapify(arr, len);
    while (len != 1) {
        swap(arr, 0, len - 1);
        siftdown(arr, len - 1, 0);
        len--;
    }
}

void test_heapsort() {
    for (int i = 0; i < 10; i++) {
        int* arr = random_array(100, 10000000);
        heapsort(arr, 100);
        assert(is_sorted(arr, 100));
        free(arr);
    }
    printf("heapsort: ok!");
}

int main(void){
    test_heapsort();
    return 0;
}
