#ifndef KNN
#define KNN

#include <math.h>

#include "mnist_helper.h"
#include "min-heap.h"
#include "kdtree.h"

#define UNUSED __attribute__((unused))


// Calcule le carré de la distance euclidienne
// entre les vecteurs d'entiers @param p1 et @param p2, 
// tous deux de dimension @param dim
int euclid_distance2(int* p1, int* p2, size_t dim);

// Définit le un type de pointeur de fonction... Ne vous souciez pas trop de la syntaxe,
// c'est juste pratique pour donner **une fonction** en argument à une autre fonction.
// En l'occurence, il s'agira d'une fonction de classification de type k-NN
typedef mnist_label_t (*knn_classifier_t) (mnist_dataset_t, mnist_picture_t, mnist_case_t **, unsigned);

// Donné un @param dataset et un @param candidate, renvoie un tableau de taille @param k
// contenant les références des @param k points du @param dataset les plus proches de @param candidate
// Le tableau sera alloué sur le tas.
mnist_case_t** knn_kclosest(mnist_dataset_t dataset, mnist_picture_t candidate, unsigned k);

// Decide a partir d'un ensemble de references @param kclosest de @param k points 
// du @param dataset de la classe a assigner, en donnant le meme poids a chacun des points
mnist_label_t knn_majority(mnist_dataset_t dataset, UNUSED mnist_picture_t candidate, mnist_case_t **kclosest, unsigned k);

// Decide a partir d'un ensemble de references @param kclosest de @param k points 
// du @param dataset de la classe a assigner, en donnant a chacun un poids proportionnel
// a l'inverse de la distance qui le separe du @param candidate
mnist_label_t knn_weighted_majority(mnist_dataset_t dataset, mnist_picture_t candidate, mnist_case_t **kclosest, unsigned k);

// Avec une fonction de classification type k-NN fournie @param classifier et un dataset @param training,
// applique la methode fournie a chaque element de l'ensemble de test @param testing en considerant @param k
// voisins. Le dernier argument précise s'il faut ou non construire un arbre k-d pour
// l'algorithme de classification. Renvoie la matrice de confusion applatie par lignes.
double* knn_confusion_matrix(knn_classifier_t classifier, mnist_dataset_t training, mnist_dataset_t testing, unsigned k, bool need_tree);


#endif /* KNN */
