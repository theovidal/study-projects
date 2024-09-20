#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include "vect.h"

int DEBUG = 0;

typedef int sat;

const sat SAT = 0;
const sat UNSAT = 1;
const sat UNKNOWN = 2;

typedef int litteral;

struct cnf {
    litteral **clauses;
    int nb_clauses;
    int nb_variables;
};

typedef struct cnf cnf;

// Utility function, you shouldn't have to call it directly.
int* read_clause(FILE *fp){
    vect c = vect_make();
    while (true) {
        int litt;
        if (fscanf(fp, "%d", &litt) != 1) assert(false);
        if (litt == 0) break;
        vect_push(c, litt);
    }

    int *clause = malloc((1 + vect_length(c)) * sizeof(int));
    clause[0] = vect_length(c);
    for (int i = 1; i <= vect_length(c); i++) {
        clause[i] = vect_get(c, i - 1);
    }

    vect_free(c);
    return clause;
}


// Input : a file pointer fp. The corresponding file should be open
// for reading, and contain a cnf formula in DIMACS format.
//
// Output : a cnf* pointing to a representation of the formula.
//
// Note : the function does not close the file.
cnf *read_cnf(FILE *fp){
    cnf *f = malloc(sizeof(cnf));

    // skip initial comments
    char header = fgetc(fp);
    while (header == 'c') {
        while (fgetc(fp) != '\n') {}
        header = fgetc(fp);
    }

    // line should be "p x y"
    assert(header == 'p');

    fscanf(fp, " cnf %d %d", &f->nb_variables, &f->nb_clauses);
    f->clauses = malloc(f->nb_clauses * sizeof(int*));

    for (int i = 0; i < f->nb_clauses; i++) {
        f->clauses[i] = read_clause(fp);
    }

    return f;
}


// Frees all the memory associated with f, including
// the struct itself. Assumes f is heap-allocated, which will
// be the case if it was obtained through a call to read_cnf or
// cnf_copy.
void cnf_free(cnf *f){
    for (int i = 0; i < f->nb_clauses; i++) {
        free(f->clauses[i]);
    }
    free(f->clauses);
    free(f);
}

// Returns a deep copy of the cnf pointed to by f.
// Only the active parts of the formula are copied
// (eg not the previously deleted clauses and litterals).
cnf *cnf_copy(cnf *f){
    cnf *g = malloc(sizeof(cnf));
    g->nb_variables = f->nb_variables;
    g->nb_clauses = f->nb_clauses;
    g->clauses = malloc(g->nb_clauses * sizeof(litteral*));
    for (int i = 0; i < g->nb_clauses; i++) {
        int *clause = f->clauses[i];
        g->clauses[i] = malloc((clause[0] + 1) * sizeof(litteral));
        for (int j = 0; j <= clause[0]; j++) {
            g->clauses[i][j] = clause[j];
        }
    }
    return g;
}

// Prints a formula on stderr
void print_cnf(cnf *f){
    fprintf(stderr, "nb_clauses = %d\n", f->nb_clauses);
    fprintf(stderr, "nb_variables = %d\n", f->nb_variables);
    for (int i = 0; i < f->nb_clauses; i++){
        fprintf(stderr, "Size %d :", f->clauses[i][0]);
        for (int j = 1; j <= f->clauses[i][0]; j++) {
            fprintf(stderr, " %d", f->clauses[i][j]);
        }
        fprintf(stderr, "\n");
    }
}

// Dans toutes les clauses, clause[0] = nb_variables et taille d'une clause = nb_variables +1 !

sat remove_clause(cnf *f, int clause_index) {
    f->clauses[clause_index] = f->clauses[f->nb_clauses - 1];
    f->nb_clauses--;

    if (f->nb_clauses == 0) return SAT;
    else return UNKNOWN;
}

sat remove_litteral(litteral clause[], int lit_index) {
    litteral nb_var = clause[0];
    clause[lit_index] = clause[nb_var];
    clause[0] = nb_var - 1;
    if (clause[0] == 0) return UNSAT;
    else return UNKNOWN;
}

int get_litteral_occurrence(litteral clause[], litteral l) {
    int l_index = 1;
    litteral nb_var = clause[0];
    int i = 1;
    while (i <= nb_var && clause[i] != l) i++;

    if (i <= nb_var) return i;
    else return 0;
}

sat assert_litteral(cnf* f, litteral valuation[], litteral l) {
    sat is_sat = UNKNOWN;
    valuation[abs(l)] = l;
    for (int i = 0; i < f->nb_clauses; i++) {
        int li_pos = get_litteral_occurrence(f->clauses[i], l);
        if (li_pos != 0) {
            is_sat = remove_clause(f, i);
            if (is_sat == SAT) break;
        }

        int li_neg = get_litteral_occurrence(f->clauses[i], -l);
        if (li_neg != 0) {
            is_sat = remove_litteral(f->clauses[i], li_neg);
            if (is_sat == UNSAT) break;
        }
    }
    return is_sat;
}

litteral get_unit_litteral(cnf *f) {
    litteral l = 0;
    for (int i = 0; i < f->nb_clauses; i++) {
        if (f->clauses[i][0] == 1) {
            l = f->clauses[i][1];
            break;
        }
    }
    return l;
}

sat unit_propagation(cnf *f, int *valuation) {
    sat is_sat = UNKNOWN;
    while (is_sat == UNKNOWN) {
        litteral l = get_unit_litteral(f);
        if (l == 0) break;
        is_sat = assert_litteral(f, valuation, l);
    }
    return is_sat;
}

struct litt_occurrences {
    int pos;
    int neg;
};

typedef struct litt_occurrences litt_occurrences;

void count_occurrences(cnf *f, litt_occurrences occs[]) {
    for (int i = 0; i < f->nb_variables; i++) {
        occs[i].pos = 0;
        occs[i].neg = 0;
    }

    for (int i = 0; i < f->nb_clauses; i++) {
        for (int x = 1; x < f->clauses[i][0]; x++) {
            litteral l = f->clauses[i][x];
            if (l < 0) occs[abs(l)].neg++;
            else occs[abs(l)].pos++;
        }
    }
}

litteral get_pure_litteral(cnf *f, litt_occurrences *occs) {
    for (int l = 0; l < f->nb_variables; l++) {
        if (occs[l].neg == 0 && occs[l].pos > 0) return l;
    }
    return 0;
}

litteral get_decision_litteral(cnf *f, litt_occurrences *occs) {
    count_occurrences(f, occs);
    int nmax_p = 0;
    int lmax_p = 0;

    int nmax_n = 0;
    int lmax_n = 0;

    for (int l = 0; l < f->nb_variables; l++) {
        if (occs[l].pos > nmax_p) {
            nmax_p = occs[l].pos;
            lmax_p = l;
        }
        if (occs[l].neg > nmax_n) {
            nmax_n = occs[l].neg;
            lmax_n = l;
        }
    }

    if (nmax_p >= nmax_n) return lmax_p;
    else return -lmax_n;
}

void print_valuation(FILE *fp, int *valuation, int len){
    for (int i = 1; i < len; i++) {
        fprintf(fp, "%d ", valuation[i]);
    }
    fprintf(fp, "0\n");
}

int* dpll_aux(cnf* f, bool* satisfiable);m

int *dpll(cnf *f, bool *satisfiable) {
    int* valuation = malloc((f->nb_variables + 1) * sizeof(int));
    sat is_sat = unit_propagation(f, valuation);
    if (is_sat == SAT || f->nb_clauses == 0) {
        *satisfiable = true;
        return valuation;
    } else if (is_sat == UNSAT) {
        *satisfiable = false;
        return valuation;
    }

    litt_occurrences* occs = malloc(f->nb_variables * sizeof(litt_occurrences));
    count_occurrences(f, occs);

    while {
        get_decision_litteral
    }
}

bool check_solution(cnf *f, int *valuation){
    for (int i = 0; i < f->nb_clauses; i++){
        int *clause = f->clauses[i];
        bool ok = false;
        for (int j = 1; j <= clause[0] && !ok; j++) {
            litteral x = clause[j];
            if (valuation[abs(x)] == x) ok = true;
        }
        if (!ok) return false;
    }
    return true;
}



int main(int argc, char* argv[]){
    DEBUG = 0;

    return 0;
}
