#include "../headers/knn.h"

int euclid_distance2(int *p1, int *p2, size_t dim)
{
    int dist = 0;
    for (int i = 0; i < dim; i++) {
        dist += (p1[i] - p2[i]) * (p1[i] - p2[i]);
    }
    return dist;
}

mnist_case_t **knn_kclosest(mnist_dataset_t dataset,
                            mnist_picture_t candidate,
                            unsigned k)
{
    int* dists = malloc(dataset.case_num * sizeof(int));
    int dim = dataset.height * dataset.width;
    for (int i = 0; i < dataset.case_num; i++) {
        dists[i] = euclid_distance2(candidate, dataset.cases[i].picture, dim);
    }

    min_heap mh = mh_create(k);
    for (int i = 0; i < k; i++) {
      mh_insert(mh, -dists[i], &dataset.cases[i]);
    }
    
    for (int i = k; i < dataset.case_num; i++) {
      if (dists[i] < -mh_first(mh)->weight) {
        mh_pop(mh);
        mh_insert(mh, -dists[i], &dataset.cases[i]);
      }
    }
    mnist_case_t** knn = malloc(k * sizeof(mnist_case_t*));
    for (int i = 0; i < k; i++) {
      knn[i] = (mnist_case_t*)mh_pop(mh);
    }
    mh_free(mh);
    free(dists);
    return knn;
}

mnist_label_t knn_majority(mnist_dataset_t dataset,
                           mnist_picture_t candidate,
                           mnist_case_t **kclosest,
                           unsigned k){
  int* labels = malloc((dataset.max_label + 1) * sizeof(int));
  for (int i = dataset.min_label; i <= dataset.max_label; i++) {
    labels[i] = 0;
  }

  for (int i = 0; i < k; i++) {
    mnist_case_t cas = *kclosest[i];
    labels[cas.label]++;
  }

  mnist_label_t max_l = dataset.min_label;
  int max_card = labels[dataset.min_label];

  for (int i = dataset.min_label + 1; i <= dataset.max_label; i++) {
    if (labels[i] > max_card) {
      max_card = labels[i];
      max_l = i;
    }
  }
  free(labels);
  return max_l;
}

mnist_label_t knn_weighted_majority(mnist_dataset_t dataset,
                           mnist_picture_t candidate,
                            mnist_case_t **kclosest,
                            unsigned k){
  int* labels = malloc((dataset.max_label + 1) * sizeof(int));
  for (int i = dataset.min_label; i <= dataset.max_label; i++) {
    labels[i] = 0;
  }

  int dim = dataset.width * dataset.height;

  for (int i = 0; i < k; i++) {
    mnist_case_t* cas = kclosest[i];
    labels[cas->label] += 1 / (1 + euclid_distance2(candidate, cas->picture, dim));
  }

  mnist_label_t max_l = dataset.min_label;
  int max_card = labels[dataset.min_label];

  for (int i = dataset.min_label + 1; i <= dataset.max_label; i++) {
    if (labels[i] > max_card) {
      max_card = labels[i];
      max_l = i;
    }
  }
  free(labels);
  return max_l;
}

double *knn_confusion_matrix(knn_classifier_t classifier,
                             mnist_dataset_t training,
                             mnist_dataset_t testing,
                             unsigned k,
                             bool need_tree)
{
  kdtree_t* tree = NULL;
  if (need_tree) {
    tree = kdtree_build(training);
    printf("Built tree\n");
  }
  int nb_classes = training.max_label - training.min_label + 1;
  double* mat = malloc(nb_classes * nb_classes * sizeof(double));
  for (int i = 0; i < nb_classes * nb_classes; i++) {
    mat[i] = 0;
  }
  int* cards = malloc(nb_classes * sizeof(int));
  for (int i = 0; i < nb_classes; i++) {
    cards[i] = 0;
  }

  for (int i = 0; i < testing.case_num; i++) {
    mnist_picture_t candidate = testing.cases[i].picture;

    mnist_case_t** kclosest = NULL;
    if (need_tree) kclosest = kdtree_knn(tree, candidate, training.case_num, k);
    else kclosest = knn_kclosest(training, candidate, k);

    int expected_label = testing.cases[i].label;
    int attributed_label = classifier(training, candidate, kclosest, k);
    mat[expected_label * nb_classes + attributed_label]++;
    cards[expected_label]++;
    printf("Treated %d cases\n", i);
    if (i % 50 == 0) printf("%d/%d cases done\n", i, testing.case_num);
  }

  for (int i = 0; i < nb_classes; i++) {
    for (int j = 0; j < nb_classes; j++) {
      if (cards[i] != 0) {
        mat[i * nb_classes + j] /= cards[i];
      }
    }
  }

  kdtree_delete(tree);
  free(cards);
  return mat;
}
