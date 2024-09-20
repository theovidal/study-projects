#include <stdio.h>
#include <stdbool.h>
#include <math.h>

int absolue(int x) {
    if (x < 0) return -x;
    else return x;
}

void affiche_si_pair(int x) {
    if (x % 2 == 0) printf("%d\n", x);
}

bool est_premier(int n) {
    if (n < 2) return false;
    for (int i = 2; i <= sqrt(n); i++) {
        if (n % i == 0 && i != n) return false;
    }
    return true;
}

int main(void) {
    printf("|5| = %d; |-5| = %d\n", absolue(5), absolue(-5));
    affiche_si_pair(5);
    affiche_si_pair(4);

    for (int i = 0; i < 20; i++) {
        if (est_premier(i)) printf("%d est premier\n", i);
        else printf("%d n'est pas premier\n", i);
    }

    return 0;
}
