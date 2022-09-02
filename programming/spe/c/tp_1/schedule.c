#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "task.h"

int total_penalty(task tasks[], int nb_tasks) {
    int penalty = 0;
    for (int i = 0; i < nb_tasks; i++) {
        if (tasks[i].start >= tasks[i].deadline)
            penalty += tasks[i].penalty;
    }
    return penalty;
}

void print_schedule(task tasks[], int nb_tasks) {
    for (int i = 0; i < nb_tasks; i++) {
        print_task(tasks[i]);
    }
    printf("-------\ntotal penalty: %d", total_penalty(tasks, nb_tasks));
}

int compare_penalties(const void* a, const void *b) {
    task* ta = (task*)a;
    task* tb = (task*)b;
    return tb->penalty - ta->penalty;
}

int compare_starts(const void* a, const void *b) {
    task* ta = (task*)a;
    task* tb = (task*)b;
    return ta->start - tb->start;
}

void schedule(task tasks[], int nb_tasks) {
    qsort(tasks, nb_tasks, sizeof(task), compare_penalties);

    int* tm = malloc(nb_tasks * sizeof(int));
    int i_tm = 0;
    bool* D = malloc(nb_tasks * sizeof(bool));
    for (int i = 0; i < nb_tasks; i++) {
        D[i] = true;
    }
    for (int i = 0; i < nb_tasks; i++) {
        bool available = false;
        for (int d = tasks[i].deadline - 1; d >= 0; d--) {
            if (D[d]) {
                tasks[i].start = d;
                D[d] = false;
                available = true;
                break;
            }
        }
        if (!available) {
            tm[i_tm] = i;
            i_tm++;
        }
    }
    for (int d = 0; d < nb_tasks; d++) {
        if (D[d]) {
            i_tm--;
            tasks[tm[i_tm]].start = d;
        }
    }
    qsort(tasks, nb_tasks, sizeof(task), compare_starts);
    free(D);
    free(tm);
}
