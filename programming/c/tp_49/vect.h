#ifndef VECT_H
#define VECT_H

typedef int T;
struct vect;
typedef struct vect* vect;

vect vect_make(void);

void vect_free(vect v);

int vect_length(vect v);

T vect_get(vect v, int i);

void vect_set(vect v, int i, T x);

int vect_pop(vect v);

void vect_push(vect v, T x);


#endif
