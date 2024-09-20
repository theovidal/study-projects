#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <stdbool.h>
#include <time.h>

typedef uint32_t ui;

const int BLOCK_SIZE = 5;
const int RADIX = 32;
const int MASK = 31;

void print_array(ui* t, int len){
  if (len > 20) { len = 20; }
  for (int i = 0; i < len; i++){
    printf("%llu\n", (long long unsigned)t[i]);
  }
  printf("\n");
}

bool is_sorted(ui *arr, int len){
  for (int i = 0; i < len - 1; i++){
    if (arr[i] > arr[i + 1]){
      return false;
    }
  }
  return true;
}

ui* rand_array(int len){
  ui* t = malloc(len * sizeof(ui));
  for (int i = 0; i < len; i++){
    t[i] = (ui)rand() * (ui)rand();
  }
  return t;
}

void copy(ui *out, ui *in, int len) {
  memcpy(out, in, len * sizeof(ui));
}

void zero_out(int *arr, int len) {
  for (int i = 0; i < len; i++) {
    arr[i] = 0;
  }
}

ui extract_digit(ui n, int k) {
  return (n >> (k * BLOCK_SIZE)) & MASK;
}

int* histogram(ui *arr, int len, int k) {
  int* hist = (int*)malloc(RADIX * sizeof(int));
  zero_out(hist, RADIX);

  for (int i = 0; i < len; i++) {
    int digit = extract_digit(arr[i], k);
    hist[digit]++;
  }

  return hist;
}

int* prefix_sums(int* hist, int len) {
  int* sums = (int*)malloc(len * sizeof(int));
  sums[0] = 0;
  int acc = 0;

  for (int i = 1; i < len; i++) {
    acc += hist[i - 1];
    sums[i] = acc;
  }
  return sums;
}

void radix_pass(ui *out, ui *in, int len, int k) {
  zero_out(out, len);
  int* hist = histogram(in, len, k);
  int* sums = prefix_sums(hist, RADIX);

  for (int i = 0; i < len; i++) {
    int digit = extract_digit(in[i], k);
    out[sums[digit]] = in[i];
    sums[digit]++;
  }

  free(hist);
  free(sums);
}

void radix_sort(ui *in, int len) {
  int nb_digits = 1 + (sizeof(ui) * 8 - 1) / BLOCK_SIZE;

  for (int k = 0; k < nb_digits; k++) {
    int* out = (int*)malloc(len * sizeof(ui));
    radix_pass(out, in, len, k);
    copy(in, out, len);
    free(out);
  }
}

int main(void){
  int len = 11;
  int arr[] = {3, 9, 1, 90, 45, 23, 78, 1, 29, 7, 38};
  radix_sort(arr, len);
  print_array(arr, len);
  return 0;
}
