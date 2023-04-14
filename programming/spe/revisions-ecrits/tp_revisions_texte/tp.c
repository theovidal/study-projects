#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#define B 256
#define P 1869461003

int naive_string_search(char* m, char* t) {
    int nb_occs = 0;
    int len_txt = strlen(t);
    int len_mot = strlen(m);
    for (int i = 0; i < len_txt - len_mot; i++) {
        if (strncmp(m, &t[i], len_mot) == 0) {
            nb_occs++;
            printf("Occurence au caractère %d\n", i + 1);
        }
    }
    return nb_occs;
}

int** build_table(char* m, int lm) {
    int** table = malloc(lm * sizeof(int*));
    for (int i = 0; i < lm; i++) {
        table[i] = malloc(256 * sizeof(int));
        for (int c = 0; c < 256; c++) {
            table[i][c] = -1;
        }
    }
    for (int i = 1; i < lm; i++) {
        int previous_letter = (int)m[i-1];
        for (int x = 0; x < 256; x++) {
            if (x == previous_letter) table[i][x] = i - 1;
            else table[i][x] = table[i - 1][x];
        }
    }
    return table;
}

void free_table(int** table, int lm) {
    for (int i = 0; i < lm; i++) {
        free(table[i]);
    }
    free(table);
}

int boyer_moore(char* m, char* t) {
    int lm = strlen(m);
    int lt = strlen(t);
    int** table = build_table(m, lm);
    int nb_occs = 0;

    int i = 0;
    while (lt - i >= lm) {
        bool found = true;
        for (int j = lm - 1; j >= 0; j--) {
            if (t[i + j] != m[j]) {
                int letter = (int)t[i+j];
                i += j - table[j][letter];
                printf("Décalage de %d jusqu'à l'indice %d\n", j - table[j][letter], i);
                found = false;
                break;
            }
        }
        if (found) {
            printf("Occurence trouvée à l'indice %d\n", i);
            nb_occs++;
            i++;
        }
    }

    free_table(table, lm);
    return nb_occs;
}

uint64_t math_power_mod(uint64_t x, uint64_t n, uint64_t p) {
    if (n == 0) return 1;
    else if (n % 2 == 0) return math_power_mod(x * x, n/2, p);
    else return (x * math_power_mod (x * x, (n - 1)/2, p)) % p;
}

uint64_t rk_hash(char* s, int len) {
    uint64_t h = 0;
    for (int i = len - 1; i >= 0; i--) {
        h = h * B + (int)s[i];
    }
    return h;
}

int rabin_karp(char* m, char* t) {
    int 
    uint64_t BP = math_power_mod(B, , uint64_t p);
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        return 0;
    }
    printf("%d\n", boyer_moore(argv[1], argv[2]));
    return 0;
}
