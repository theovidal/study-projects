#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

/*************/
/*  Partie 1 */
/*************/

typedef int datatype;

typedef struct Node {
  datatype data;
  struct Node* next;
} Node;


// Exercice 1

Node* new_node(datatype data) {
    Node* new = malloc(sizeof(Node));
    new->data = data;
    new->next = NULL;
    return new;
}

Node* cons(Node* list, datatype data) {
    Node* result = new_node(data);
    result->next = list;
    return result;
}

Node* from_array(datatype array[], int len) {
    Node* result = NULL;
    for (int i = len - 1; i >= 0; i--) {
        result = cons(result, array[i]);
    }
    return result;
}


// Exercice 2

void free_list(Node* n) {
    if (n != NULL) {
        free_list(n->next);
        free(n);
    }
}

// Généralité des fonctions impératives : tant que le pointeur n'est pas nul,
// on fait nos actions puis on pointe vers le suivant
int length(Node* list) {
    Node* current = list;
    int length = 0;
    while (current != NULL) {
        length++;
        current = current->next;
    }
    return length;
}

void print_list(Node* n, bool newline) {
    printf("[");
    while (n != NULL) {
        printf("%d", n->data);
        if (n->next != NULL) printf(" ");
        n = n->next;
    }
    printf("]");
    if (newline) printf("\n");
}

void test_length(void){
  assert(length(NULL) == 0);
  Node* u = cons(cons(NULL, 3), 4);
  assert(length(u) == 2);
  int t[3] = {2, 4, 6};
  free_list(u);
  u = from_array(t, 3);
  assert(length(u) == 3);
  assert(u->data == 2);
  free_list(u);
}


datatype* to_array(Node* u) {
    int len = length(u);
    datatype* result = malloc(len * sizeof(datatype));
    for (int i = 0; i < len; i++) {
        Node* next = u->next;
        result[i] = u->data;
        u = next;
    }
    return result;
}

void test_to_array(void){
  int t[5] = {1, 2, 3, 4, 5};
  int n = 5;
  Node* u = from_array(t, n);
  print_list(u, false);
  int* t2 = to_array(u);
  for (int i = 0; i < n; i++){
    assert(t[i] == t2[i]);
  }
  free(t2);
  free_list(u);
}

// Big brain function
bool is_equal(Node* u, Node* v) {
    while (u != NULL && v != NULL && u->data == v->data) {
        u = u->next;
        v = v->next;
    }
    return u == NULL && v == NULL;
}

void test_is_equal(void){
  int a[4] = {1, 2, 3, 4};
  int b[4] = {1, 2, 3, 3};

  Node* u = from_array(a, 3);
  Node* v = from_array(a, 4);
  assert(!is_equal(u, v));
  free_list(u);
  free_list(v);

  u = from_array(a, 4);
  v = from_array(b, 4);
  assert(!is_equal(u, v));
  free_list(u);
  free_list(v);

  u = from_array(a, 2);
  v = from_array(b, 2);
  assert(is_equal(u, v));

  free_list(u);
  free_list(v);
}

// Exercice 3

// Also big brain function
bool is_sorted(Node* u) {
    if (u == NULL) return true;
    while (u->next != NULL && u->data <= u->next->data) {
        u = u->next;
    }
    return u->next == NULL;
}

void test_is_sorted(void){
  int t[5] = {1, 2, 4, 3, 5};

  Node* u = from_array(t, 0);
  assert(is_sorted(u));
  free_list(u);

  u = from_array(t, 1);
  assert(is_sorted(u));
  free_list(u);

  u = from_array(t, 3);
  assert(is_sorted(u));
  free_list(u);

  u = from_array(t, 4);
  assert(!is_sorted(u));
  free_list(u);

  u = from_array(t, 5);
  assert(!is_sorted(u));
  free_list(u);
}

Node* insert_rec(Node* u, datatype x) {
  if (u == NULL) return new_node(x); // Si on arrive à la fin, on crée l'unique noeud qu'il faut
  if (u->data > x) return cons(u, x); // Si on arrive au bon emplacement de x, on crée l'unique noeud qu'il faut
  u->next = insert_rec(u->next, x);
  return u;
}

void test_insert_rec(void){
  Node* u = NULL;
  u = insert_rec(u, 4);
  u = insert_rec(u, 2);
  u = insert_rec(u, 3);
  u = insert_rec(u, 5);

  int t[4] = {2, 3, 4, 5};
  Node* v = from_array(t, 4);
  assert(is_equal(u, v));

  free_list(u);
  free_list(v);
}


Node* insertion_sort_rec(Node* u) {
  if (u == NULL) return u;
  return insert_rec(insertion_sort_rec(u->next), u->data);
}

void test_insertion_sort_rec(void){
  int t[5] = {0, 4, 2, 1, 3};
  int t_sorted[5] = {0, 1, 2, 3, 4};

  Node* u = from_array(t, 5);
  Node* v = insertion_sort_rec(u);
  Node* w = from_array(t_sorted, 5);

  assert(is_equal(v, w));

  free_list(u);
  free_list(v);
  free_list(w);
}


// Exercice 4

Node* reverse_copy(Node* u) {
  Node* v = NULL;
  while (u != NULL) {
    v = cons(v, u->data);
    u = u->next;
  }
  return v;
}

void test_reverse_copy(void){
  int t[4] = {1, 2, 3, 4};
  int t_rev[4] = {4, 3, 2, 1};
  Node* u = from_array(t, 4);
  Node* v = from_array(t_rev, 4);

  Node* u_rev = reverse_copy(u);
  assert(is_equal(v, u_rev));

  free_list(u);
  free_list(v);
  free_list(u_rev);
}

Node* copy_rec(Node* u) {
  if (u == NULL) return NULL;
  else return cons(copy_rec(u->next), u->data);
}

void test_copy_rec(void){
  int t1[4] = {1, 2, 3, 4};
  Node* u = from_array(t1, 4);
  Node* v = copy_rec(u);

  assert(is_equal(u, v));
  free_list(u);
  free_list(v);
}

// - On parcourt bien sûr la liste u.
// - On "parcourt" la copie, dans le sens où on ajoute un noeud puis passe au next, donc current
//   stocke le noeud courant
// - Ce qu'on doit renvoyer est bien le début de la liste, qu'on conserve à un endroit, soit start.
//   (start est bien modifié puisque current est au départ strictement le même pointeur)
Node* copy(Node* u) {
  if (u == NULL) return NULL;
  Node* start = new_node(u->data);
  Node* current = start;
  while (u->next != NULL) {
    u = u->next;
    Node* new = new_node(u->data);
    current->next = new;
    current = current->next;
  }
  return start;
}

void test_copy(void){
  int t1[4] = {1, 2, 3, 4};
  Node* u = from_array(t1, 4);
  Node* v = copy(u);

  assert(is_equal(u, v));
  free_list(u);
  free_list(v);

  u = NULL;
  v = copy(u);
  assert(is_equal(u, v));
}

Node* reverse(Node* u) {
  if (u == NULL || u->next == NULL) return u;
  Node* next = u->next;
  Node* current = u;

  // ça doit bien être le début de la liste retournée (ne pas créer de boucle au début)
  current->next = NULL; 

  while (next != NULL) {
    Node* temp = current;
    current = next;
    next = next->next;
    current->next = temp;
  }
  return current;
} 

void test_reverse(void){
  int t[4] = {1, 2, 3, 4};
  Node* u = from_array(t, 4);
  Node* u_rev = reverse_copy(u);


  u = reverse(u);
  assert(is_equal(u, u_rev));

  free_list(u);
  free_list(u_rev);

  u = NULL;
  u = reverse(u);
  assert(is_equal(u, NULL));
}


// Exercice 5

Node* read_list(void) {
  Node* result = NULL;
  while (true) {
    datatype x;
    int nb = scanf("%d", &x);
    if (nb == 1) result = cons(result, x);
    else return result;
  }
}

/*
int main(void) {
  Node* list = read_list();
  Node* sorted = insertion_sort_rec(list);
  print_list(sorted, true);
  free_list(list);
  free_list(sorted);
  return 0;
}
*/

//  Partie 2 //


typedef struct Stack {
  int len;
  Node* top;
} Stack;

// Exercice 6

Stack* empty_stack(void) {
  Stack* new = malloc(sizeof(Stack));
  new->len = 0;
  new->top = NULL;
  return new;
}

datatype peek(Stack* s) {
  assert(s->len > 0);
  return s->top->data;
}

void push(Stack* s, datatype x) {
  s->len++;
  s->top = cons(s->top, x);
}

datatype pop(Stack* s) {
  assert(s->len > 0);
  s->len--;
  Node* top = s->top;
  datatype x = top->data;
  s->top = s->top->next;
  free(top);
  return x;
}

void free_stack(Stack* s) {
  free_list(s->top);
  free(s);
}

void test_stack(void){
  Stack* s = empty_stack();
  push(s, 1);
  push(s, 2);
  assert(pop(s) == 2);
  push(s, 3);
  assert(pop(s) == 3);
  assert(pop(s) == 1);
  assert(s->len == 0);
  push(s, 10);
  assert(pop(s) == 10);
  free_stack(s);
}


// Files

typedef struct Queue {
  int len;
  Node* left;
  Node* right;
} Queue;


// Exercice 7

Queue* empty_queue(void) {
  Queue* new = malloc(sizeof(Queue));
  new->len = 0;
  new->left = NULL;
  new->right = NULL;
  return new;
}

void free_queue(Queue* q) {
  free_list(q->left);
  free(q);
}

datatype peek_left(Queue* q) {
  assert(q->len > 0);
  return q->left->data;
}

void push_right(Queue* q, datatype data) {
  Node* n = new_node(data);
  if (q->right == NULL) {
    q->right = n;
    q->left = n;
  } else {
    q->right->next = n;
    q->right = n;
  }
  q->len++;
}

datatype pop_left(Queue* q) {
  assert(q->len > 0);
  datatype x = q->left->data;
  if (q->len == 1) {
    free_list(q->left); // La véritable liste se situe à gauche, "celle de droite" y pointe 
    q->left = NULL;
    q->right = NULL;
  } else {
    Node* next = q->left->next;
    free(q->left);
    q->left = next;
  }
  q->len--;
  return x;
}

void test_queue(void){
  Queue* q = empty_queue();
  push_right(q, 1);
  push_right(q, 2);
  assert(pop_left(q) == 1);
  push_right(q, 3);
  push_right(q, 4);
  assert(pop_left(q) == 2);
  assert(pop_left(q) == 3);
  assert(pop_left(q) == 4);
  push_right(q, 5);
  assert(pop_left(q) == 5);
  assert(q->len == 0);
  free_queue(q);
}

int main(void) {
  test_queue();
}
/*
// Exercice 8

int* hamming(int n);

void test_hamming(void){
  int n = 14;
  int h_ref[14] = {1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 18, 20};
  int* h = hamming(14);

  for (int i = 0; i < n; i++){
    assert(h[i] == h_ref[i]);
  }

  free(h);
}

//  Partie 3 //

// Exercice 9

Node* insert_it(Node* u, datatype x);

Node* insertion_sort_it(Node* u);

void test_insertion_sort_it(void){
  int t[5] = {0, 4, 2, 1, 3};
  int t_sorted[5] = {0, 1, 2, 3, 4};

  Node* u = from_array(t, 5);
  Node* v = insertion_sort_it(u);
  Node* w = from_array(t_sorted, 5);

  assert(is_equal(v, w));

  free_list(u);
  free_list(v);
  free_list(w);
}


// Exercice 10

Node* split(Node* u, int n);

void test_split(void);

Node* merge(Node* u, Node* v);

Node* merge_sort(Node* u);

void test_merge_sort(void){
  int t[10] = {1, 4, 0, 2, 3, 8, 5, 6, 6, 7};
  Node* u = from_array(t, 10);

  u = merge_sort(u);
  Node* u_sorted = insertion_sort_it(u);
  assert(is_equal(u, u_sorted));

  free_list(u);
  free_list(u_sorted);
}
*/