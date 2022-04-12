#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

int count_names(char* filename) {
    FILE* f = fopen(filename, "r");
    int count = 0;
    char next;
    while (fscanf(f, "%c", &next) != EOF) {
        if (next == '\n') count++;
    }
    fclose(f);
    return count;
}

int count_names_prefix(char* filename, char prefix) {
    FILE* f = fopen(filename, "r");
    int count = 0;
    char next[100]; // Un prénom fera rarement plus de 100 caractères...
    while (fgets(next, 100, f) != NULL) {
        if (next[0] == prefix) count++;
    }
    fclose(f);
    return count;
}

bool contains_letter(char* name, char letter) {
    for (int i = 0; name[i] != '\0'; i++) {
        if (name[i] == letter) return true;
    }
    return false;
}

float count_contains_letter(char* filename, char letter) {
    FILE* f = fopen(filename, "r");
    int count = 0;
    int total = 0;
    char next[100];
    while (fgets(next, 100, f) != NULL) {
        total++;
        if (contains_letter(next, letter)) count++;
    }
    fclose(f);
    return (float)count/(float)total;
} 

bool is_palindromic(char* name) {
    int length = strlen(name) - 1;

    for (int i = 0; i <= length / 2; i++) {
        int j = length - i - 1;
        if (name[i] != name[j]) return false;
    }
    return true;
}

void print_palindromic(char* filename) {
    FILE* f = fopen(filename, "r");
    char next[100];
    while (fgets(next, 100, f) != NULL) {
        if (is_palindromic(next)) printf("%s", next);
    }
    fclose(f);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Il faut passer un nom de fichier en argument");
        return -1;
    }
    char* filename = argv[1];
    print_palindromic(filename);
}
