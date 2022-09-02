#ifndef SCHEDULE_H
#define SCHEDULE_H

#include "task.h"

int total_penalty(task tasks[], int nb_tasks);
void print_schedule(task tasks[], int nb_tasks);
void schedule(task tasks[], int nb_tasks);

#endif