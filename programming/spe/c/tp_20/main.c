#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include <unistd.h>
#include <math.h>

#include "mnist_helper.h"
#include "knn.h"

// ----- Program entry point ----- //

static void print_help(char *prog_name)
{
    printf("TP23 -- k-NN\n\n");
    printf("Usage:\n%s training_pictures training_labels testing_pictures testing_labels\n\n", prog_name);
    printf(
        "Construit un k-NN classifier basé sur le dataset au format MNIST donné en entrée\n"
        "et le test sur le second dataset.\n"
        "On peut spécifier avec l'argument optionel 'p' la fraction de l'ensemble de test à utiliser.\n"
        "En effet, tester l'intégralité des données peut prendre du temps. Par défaut, p = 0.1.\n\n"
        "Arguments:\n"
        "\t training_pictures: Fichier en encodage binaire MNIST contenant les données d'entrainement.\n"
        "\t training_labels  : Fichier en encodage binaire MNIST contenant les étiquettes d'entrainement.\n"
        "\t                    (Doit contenir autant de lignes que le fichier de données d'entrinement.)\n"
        "\t testing_pictures : Fichier MNIST contenant les données de test.\n"
        "\t testing_labels   : Fichier MNIST contenant les étiquettes de test (même contrainte de taille).\n"
        "\nOptions:\n"
        "\t -h            : Ecrit ce message.\n"
        "\t -d Num        : Affiche [Num] images prises au hasard dans le training dataset sur la sortie standard.\n"
        "\t -k Voisins    : Précise le nombre de voisins considéré par la méthode k-NN. 5 par défaut.\n"
        "\t -p Proportion : Proportion du fichier de tests à faire passer. Par défaut: 0.1\n"
        "\t -w            : Utilise 'knn_weighted_majority' au lieu de 'knn_majority'\n"
        "\t -t            : Utilise un arbre k-d pour la recherche des plus proches voisins\n");
}

int main(int argc, char *argv[])
{
    unsigned d = 0;
    int c;
    unsigned k = 5;
    double p = 0.1;
    bool use_weighted = false;
    bool use_kdtree = false;

    while ((c = getopt(argc, argv, "hd:k:p:wt")) != -1)
    {
        switch (c)
        {
        case 'h':
            print_help(argv[0]);
            exit(0);
            break;
        case 'd':
            d = strtol(optarg, NULL, 0);
            break;
        case 'w':
            use_weighted = true;
            break;
        case 't':
            use_kdtree = true;
            break;
        case 'k':
            k = strtol(optarg, NULL, 0);
            if (k <= 0)
            {
                fprintf(stderr, "Nombre de voisins à considérer nul!\nFin du programme...\n");
                exit(1);
            }
            break;
        case 'p':
            p = strtod(optarg, NULL);
            if (p <= 0)
            {
                fprintf(stderr, "Proportion de tests négative (%f)!\nFin du programme...\n", p);
                exit(1);
            }
            else if (p > 1)
            {
                fprintf(stderr, "Proportion de tests strictement supérieure à 1 (%f)!\nFin du programme...\n", p);
                exit(1);
            }
            break;

        case '?':
            if (isprint(optopt))
                fprintf(stderr, "Option inconnue `-%c'.\nFin du programme...\n", optopt);
            else
                fprintf(stderr,
                        "Charactere d'option inconnu `\\x%x'.\nFin du programme...\n",
                        optopt);
            exit(1);
            break;
        default:
            abort();
            break;
        }
    }

    mnist_dataset_t training, testing;

    if (argc - (optind - 1) < 5)
    {
        fprintf(stderr, "Pas assez d'arguments!\n");
        print_help(argv[0]);
        exit(1);
    }
    else
    {
        parse_mnist(argv[1 + (optind - 1)], argv[2 + (optind - 1)], &training);
        parse_mnist(argv[3 + (optind - 1)], argv[4 + (optind - 1)], &testing);
    }

    printf("+++ Found %lu training cases\n--- Found %lu testing cases (%lu to be done)\n", training.case_num, testing.case_num, (size_t)(testing.case_num * p));
    printf("Labels range: [ %d, %d ]\n", training.min_label, training.max_label);

    if (d > 0)
    {
        srand(time(NULL));

        for (unsigned i = 0; i < d; i++)
        {
            unsigned index = rand() % training.case_num;
            printf("Printing training case number %u...\n\n", index);
            fprint_raw_mnist_pic(stdout, &training.cases[index], training.height, training.width);
            fprint_pretty_mnist_pic(stdout, &training.cases[index], training.height, training.width);
        }
    }
    else
    {
        size_t total_case_num = testing.case_num;
        testing.case_num *= p;
        double *confusion_matrix;

        if (use_weighted)
        {
            confusion_matrix = knn_confusion_matrix(knn_weighted_majority, training, testing, k, use_kdtree);
        }
        else
        {
            confusion_matrix = knn_confusion_matrix(knn_majority, training, testing, k, use_kdtree);
        }

        fprint_confusion_matrix(stdout, confusion_matrix, training.min_label, training.max_label);

        free(confusion_matrix);
        testing.case_num = total_case_num;
    }

    free_mnist_dataset(&training);
    free_mnist_dataset(&testing);
    return 0;
}
