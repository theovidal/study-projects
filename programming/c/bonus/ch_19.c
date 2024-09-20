#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

bool is_prefix(char* text, char* substring) {
    int i = 0;
    for (i = 0; substring[i] != '\0' && text[i] != '\0'; i++) {
       if (text[i] != substring[i]) return false;
    }
    return substring[i] == 0;
}

int first_occurrence(char* text, char* substring) {
    for (int i = 0; text[i] != '\0'; i++) {
        if (is_prefix(&text[i], substring)) return i;
    }
    return -1;
}

int* occurences(char* text, char* substring, int* len) {
    int count = 0;
    for (int i = 0; text[i] != 0; i++) {
        if (is_prefix(&text[i], substring)) count++;
    }
    int* res = malloc(count * sizeof(int));
    int res_pos = 0;
    for (int i = 0; text[i] != 0; i++) {
        if (is_prefix(&text[i], substring)) {
            res[res_pos] = i;
            res_pos++;
        }
    }                                                                                              
    *len = count;
    return res;
}

int main(void) {
    if (is_prefix("salut", "salutations")) printf("Yes");
    else printf("No");
}
