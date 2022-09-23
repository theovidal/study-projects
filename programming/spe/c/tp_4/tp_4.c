#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>


#define EPS 256
#define ALL 257
#define MATCH 258

#define MAX_LINE_LENGTH 1024

struct state {
    int c;
    struct state *out1;
    struct state *out2;
    int last_set;
};

typedef struct state state_t;

state_t* State_array;
int Nb_states;

struct nfa {
    state_t *start;
    state_t *final;
    int n;
};

typedef struct nfa nfa_t;

struct stack {
    int length;
    int capacity;
    nfa_t *data;
};

typedef struct stack stack_t;

struct set {
    int length;
    int id;
    state_t **states;
};

typedef struct set set_t;

state_t *new_state(int c, state_t *out1, state_t *out2) {
    state_t* new = &State_array[Nb_states];
    new->c = c;
    new->last_set = -1;
    new->out1 = out1;
    new->out2 = out2;
    Nb_states++;
    return new;
}

nfa_t character(char c) {
    nfa_t tc;
    state_t* end = new_state(MATCH, NULL, NULL);
    state_t* start = new_state(c, end, NULL);
    tc.n = 2;
    tc.start = start;
    tc.final = end;
    return tc;
}

nfa_t all(void) {
    nfa_t t_all = character(0);
    t_all.start->c = ALL;
    return t_all;
}

nfa_t concat(nfa_t a, nfa_t b) {
    nfa_t t;
    t.n = a.n + b.n;
    t.start = a.start;
    t.final = b.final;
    a.final->c = EPS;
    a.final->out1 = b.start;
    return t;
}

nfa_t alternative(nfa_t a, nfa_t b) {
    state_t* begin = new_state(EPS, a.start, b.start);
    state_t* end = new_state(MATCH, NULL, NULL);
    a.final->c = EPS;
    a.final->out1 = end;
    b.final->c = EPS;
    b.final->out1 = end;

    nfa_t t_alt;
    t_alt.start = begin;
    t_alt.final = end;
    t_alt.n = a.n + b.n + 2;
    return t_alt;
}

nfa_t star(nfa_t a) {
    state_t* end = new_state(MATCH, NULL, NULL);
    state_t* begin = new_state(EPS, a.start, end);
    a.final->c = EPS;
    a.final->out1 = end;
    a.final->out2 = a.start;

    nfa_t t_star;
    t_star.start = begin;
    t_star.final = end;
    t_star.n = a.n + 2;
    return t_star;
}

nfa_t maybe(nfa_t a) {
    nfa_t t_maybe;
    state_t* begin = new_state(EPS, a.start, a.final);
    t_maybe.start = begin;
    t_maybe.final = a.final;
    t_maybe.n = a.n + 1;
    return t_maybe;
}

stack_t *stack_new(int capacity) {
    stack_t *s = malloc(sizeof(stack_t));
    s->data = malloc(capacity * sizeof(nfa_t));
    s->capacity = capacity;
    s->length = 0;
    return s;
}

void stack_free(stack_t *s){
    free(s->data);
    free(s);
}

nfa_t pop(stack_t *s){
    assert(s->length > 0);
    nfa_t result = s->data[s->length - 1];
    s->length--;
    return result;
}

void push(stack_t *s, nfa_t a){
    assert(s->capacity > s->length);
    s->data[s->length] = a;
    s->length++;
}

nfa_t build(char *regex) {
    stack_t* s = stack_new(strlen(regex));
    for (int i = 0; regex[i] != '\0'; i++) {
        char c = regex[i];
        if (c == '@') {
            nfa_t right = pop(s);
            nfa_t left = pop(s);
            push(s, concat(left, right));
        } else if (c == '|') {
            nfa_t right = pop(s);
            nfa_t left = pop(s);
            push(s, alternative(left, right));
        } else if (c == '*') {
            nfa_t el = pop(s);
            push(s, star(el));
        } else if (c == '.')
            push(s, all());
        else if (c == '?') {
            nfa_t el = pop(s);
            push(s, maybe(el));
        }
        else
            push(s, character(c));
    }
    nfa_t t = pop(s);
    stack_free(s);
    return t;
}

bool backtrack(state_t *state, char *s) {
    /*
    if ((s[0] == '\0' || s[0] == '\n') && state->c == MATCH)
        return true;
    if (state->c == s[0] || state->c == ALL)
        return backtrack(state->out1, &s[1]);
    else if (state->c < 256 && s[0] != state->c || state->c == MATCH)
        return false;
    else {
        if (state->out2 == NULL) return backtrack(state->out1, s);
        else return backtrack(state->out1, s) || backtrack(state->out2, s);
    }*/

    // Correction: ne pas faire du pâté
    if (state == NULL) return false;
    if (state->c == EPS) {
        return backtrack(state->out1, s) || backtrack(state->out2, s);
    }
    if (s[0] == '\0' || s[0] == '\n') return state->c == MATCH;
    if (s[0] == state->c || state->c == ALL)
        return backtrack(state->out1, &s[1]);

    return false;
}

bool accept_backtrack(nfa_t a, char *s) {
    return backtrack(a.start, s);
}

void match_stream_backtrack(nfa_t a, FILE *in){
    char *line = malloc((MAX_LINE_LENGTH + 1) * sizeof(char));
    while (true) {
        if (fgets(line, MAX_LINE_LENGTH, in) == NULL) break;
        if (accept_backtrack(a, line)) {
            printf("%s", line);
        }
    }
    free(line);
}


set_t *empty_set(int capacity, int id){
    state_t **arr = malloc(capacity * sizeof(state_t*));
    set_t *s = malloc(sizeof(set_t));
    s->length = 0;
    s->id = id;
    s->states = arr;
    return s;
}

void set_free(set_t *s){
    free(s->states);
    free(s);
}


void add_state(set_t *set, state_t *s) {
    if (s == NULL || s->last_set == set->id) return;
    s->last_set = set->id;
    set->states[set->length] = s;
    set->length++;
    if (s->c == EPS) {
        add_state(set, s->out1);
        add_state(set, s->out2);
    }
}

void step(set_t *old_set, char c, set_t *new_set) {
    new_set->id = old_set->id + 1;
    new_set->length = 0;
    for (int i = 0; i < old_set->length; i++) {
        state_t* s = old_set->states[i];
        if (s->c == c || s->c == ALL)
            add_state(new_set, s->out1);
    }
}

bool accept(nfa_t a, char *s, set_t *s1, set_t *s2) {
    s1->length = 0;
    add_state(s1, a.start);
    for (int i = 0; s[i] != '\0' && s[i] != '\n'; i++) {
        step(s1, s[i], s2);
        // Pas besoin de copier le tableau! On peut directement utiliser les pointeurs
        set_t* tmp = s1;
        s1 = s2;
        s2 = tmp;
    }
    // Il n'y a qu'un état final dans un automate de Thompson : juste vérifier s'il est dans le set
    return a.final->last_set == s1->id;
}

// Les ID dans les états restent tel quel -> il faut bien incrémenter l'id du set
// pour chaque nouvelle ligne (l'id donne le nombre de caractères déjà lu (globalement))
void match_stream(nfa_t a, FILE *in) {
    set_t* s1 = empty_set(a.n, 0);
    set_t* s2 = empty_set(a.n, 1);

    char *line = malloc((MAX_LINE_LENGTH + 1) * sizeof(char));
    while (fgets(line, MAX_LINE_LENGTH, in) != NULL) {
        if (accept(a, line, s1, s2)) printf("%s", line);
        s1->id++;
    }
    free(line);
    set_free(s1);
    set_free(s2);
}

int main(int argc, char* argv[]){
    Nb_states = 0;
    if (argc < 2) {
        printf("Il faut passer une regex en argument");
        return -1;
    }
    char* regex = argv[1];
    State_array = malloc(2 * strlen(regex) * sizeof(state_t));
    FILE* in = stdin;
    if (argc > 2) in = fopen(argv[2], "r");
    nfa_t a = build(regex);
    match_stream(a, in);
    if (argc > 2) fclose(in);
    free(State_array);
    return 0;
}

