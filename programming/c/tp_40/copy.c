#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Il faut passer deux noms de fichier en argument");
        return -1;
    }
    FILE* src = fopen(argv[1], "r");
    FILE* dest = fopen(argv[2], "w");

    char next;
    while (fscanf(src, "%c", &next) != EOF) {
        if (next == 'a') next = 'e';
        if (next == 'e') next = 'a';
        fprintf(dest, "%c", next);
    }

    fclose(src);
    fclose(dest);
}
