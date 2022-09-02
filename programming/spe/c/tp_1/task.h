#ifndef TASK_H
#define TASK_H

typedef struct task {
    int id;
    int start;
    int penalty;
    int deadline;
} task;
task new_task(int id, int penalty, int deadline);
void print_task(task t);

#endif