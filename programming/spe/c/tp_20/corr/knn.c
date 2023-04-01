#include "knn.h"

int euclid_distance2(int *p1, int *p2, size_t dim)
{
    int output = 0;
    for (size_t i = 0; i < dim; i++)
    {
        output += (p1[i] - p2[i]) * (p1[i] - p2[i]);
    }
    return output;
}

mnist_case_t **knn_kclosest(mnist_dataset_t dataset, mnist_picture_t candidate, unsigned k)
{
    min_heap heap = mh_create(k);

    size_t pic_size = dataset.height * dataset.width;

    for (size_t i = 0; i < k; i++)
    {
        mh_insert(heap, -euclid_distance2(dataset.cases[i].picture, candidate, pic_size), &dataset.cases[i]);
    }

    for (size_t i = k; i < dataset.case_num; i++)
    {
        double worst_case_dist = -mh_first(heap)->weight;
        mnist_case_t *current_case = &dataset.cases[i];
        double current_case_dist = euclid_distance2(current_case->picture, candidate, pic_size);

        if (current_case_dist < worst_case_dist)
        {
            mh_pop(heap);
            mh_insert(heap, -current_case_dist, current_case);
        }
    }

    mnist_case_t **kclosest = (mnist_case_t **)malloc(sizeof(mnist_case_t *) * k);

    for (unsigned i = 0; i < k; i++)
    {
        mnist_case_t *close_case = (mnist_case_t *)mh_pop(heap);
        kclosest[i] = close_case;
    }

    mh_free(heap);

    return kclosest;
}

mnist_label_t knn_majority(mnist_dataset_t dataset, UNUSED mnist_picture_t candidate, mnist_case_t **kclosest, unsigned k)
{
    mnist_label_t label_range_size = dataset.max_label - dataset.min_label + 1;
    unsigned *votes = (unsigned *)malloc(sizeof(unsigned) * label_range_size);

    for (mnist_label_t i = 0; i < label_range_size; i++)
    {
        votes[i] = 0;
    }

    for (unsigned i = 0; i < k; i++)
    {
        votes[kclosest[i]->label - dataset.min_label] += 1;
    }

    mnist_label_t best_index = 0;
    unsigned best_value = votes[0];

    for (mnist_label_t i = 1; i < label_range_size; i++)
    {
        if (votes[i] > best_value)
        {
            best_value = votes[i];
            best_index = i;
        }
    }

    free(votes);
    return best_index;
}

mnist_label_t knn_weighted_majority(mnist_dataset_t dataset, mnist_picture_t candidate, mnist_case_t **kclosest, unsigned k)
{
    mnist_label_t label_range_size = dataset.max_label - dataset.min_label + 1;
    double *votes = (double *)malloc(sizeof(double) * label_range_size);

    for (mnist_label_t i = 0; i < label_range_size; i++)
    {
        votes[i] = 0.0;
    }

    for (unsigned i = 0; i < k; i++)
    {
        votes[kclosest[i]->label - dataset.min_label] += 1.0 / (1.0 + euclid_distance2(kclosest[i]->picture, candidate, dataset.width * dataset.height));
    }

    mnist_label_t best_index = 0;
    double best_value = votes[0];

    for (mnist_label_t i = 1; i < label_range_size; i++)
    {
        if (votes[i] > best_value)
        {
            best_value = votes[i];
            best_index = i;
        }
    }

    free(votes);
    return best_index;
}

double *knn_confusion_matrix(knn_classifier_t classifier, mnist_dataset_t training, mnist_dataset_t testing, unsigned k, bool need_tree)
{
    mnist_label_t label_range_size = training.max_label - training.min_label + 1;

    kdtree_t *tree_ptr;
    if (need_tree)
    {
        tree_ptr = (kdtree_t *)malloc(sizeof(kdtree_t));
        *tree_ptr = kdtree_build(training);
    }
    else
    {
        tree_ptr = NULL;
    }

    unsigned *confusion_matrix = (unsigned *)malloc(sizeof(unsigned) * label_range_size * label_range_size);
    for (mnist_label_t i = 0; i < label_range_size * label_range_size; i++)
    {
        confusion_matrix[i] = 0;
    }

    unsigned *testing_labels_totals = (unsigned *)malloc(sizeof(unsigned) * label_range_size);
    for (mnist_label_t i = 0; i < label_range_size; i++)
    {
        testing_labels_totals[i] = 0;
    }

    for (size_t c = 0; c < testing.case_num; c++)
    {
        mnist_label_t test_label = testing.cases[c].label;
        mnist_case_t **kclosest;
        if (need_tree)
        {
            kclosest = kdtree_knn(*tree_ptr, testing.cases[c].picture, training.height * training.width, k);
        }
        else
        {
            kclosest = knn_kclosest(training, testing.cases[c].picture, k);
        }
        mnist_label_t predicted = classifier(training, testing.cases[c].picture, kclosest, k);
        confusion_matrix[test_label * label_range_size + predicted] += 1;
        testing_labels_totals[test_label] += 1;

        if (c % (testing.case_num / 100) == 0)
        {
            printf("Done %2lu%% (%lu over %lu)\n", 100 * c / testing.case_num, c, testing.case_num);
        }
        free(kclosest);
    }

    double *normalized_confusion_matrix = (double *)malloc(sizeof(double) * label_range_size * label_range_size);
    for (size_t i = 0; i < label_range_size * label_range_size; i++)
    {
        normalized_confusion_matrix[i] = (double)confusion_matrix[i] / (double)testing_labels_totals[i / label_range_size];
    }

    free(confusion_matrix);
    free(testing_labels_totals);
    if (tree_ptr != NULL)
    {
        free(tree_ptr);
    }

    return normalized_confusion_matrix;
}
