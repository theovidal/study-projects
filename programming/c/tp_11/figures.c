#include <stdio.h>
#include <stdbool.h>

void rect(int h, int w, bool full) {
    for (int i = 1; i <= h; i++) {
        for (int j = 1; j <= w; j++) {
            if (full || (i == 1 || i == h || j == 1 || j == w)) printf("*");
            else printf(" ");
        }
        printf("\n");
    }
    printf("\n");
}

void line(int l, char c) {
    for (int i = 0; i < l; i++) {
        printf("%c", c);
    }
}

void figure_one() {
    rect(4, 5, true);
    printf("\n");
    for (int i = 1; i <= 5; i++) {
        line(i, '*');
        printf("\n");
    }
    printf("\n");
    for (int i = 6; i > 0; i--) {
        line(i, '*');
        printf("\n");
    }
}

void figure_two() {
    rect(5, 4, false);
    printf("\n");
    for (int i = 1; i <= 6; i++) {
        if (i == 6) {
            line(i, '*');
            printf("\n");
            break;
        }

        for (int j = 1; j <= i; j++) {
            if (j == 1 || j == i) printf("*");
            else printf(" ");
        }
        printf("\n");
    }
}

void figure_three(int height) {
    int length = height * 2 - 1;
    for (int i = 1; i <= height; i++) {
        int lineSize = i * 2 - 1;
        line((length - lineSize)/2, ' ');
        line(lineSize, '*');
        line((length - lineSize)/2, ' ');
        printf("\n");
    }
}

void figure_four(int height) {
    int length = height * 2 - 2;
    for (int i = 1; i <= height; i++) {
        int lineSize = i * 2 - 2;
        line((length - lineSize)/2, ' ');
        printf("/");

        if (i == height) line(lineSize, '_');
        else line(lineSize, ' ');

        printf("\\");
        line((length - lineSize)/2, ' ');
        printf("\n");
    }
}

int main(void) {
    figure_one();
    printf("\n———————————————————————\n\n");
    figure_two();
    printf("\n———————————————————————\n\n");
    figure_three(7);
    printf("\n———————————————————————\n\n");
    figure_four(8);
    return 0;
}
