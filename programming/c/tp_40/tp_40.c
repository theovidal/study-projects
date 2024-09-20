#include <stdio.h>
#include <stdlib.h>

int main(void) {
    FILE* f = fopen("blank.txt", "w");
    fprintf(f, "Première ligne\nDeuxième ligne");
    fclose(f);

    f = fopen("blank.txt", "r");
    char next;
    while (fscanf(f, "%c", &next) != EOF) {
        printf("%c", next);
    }
    fclose(f);

    f = fopen("blank.txt", "a");
    fprintf(f, "\nTroisième ligne");
    fclose(f);
}
