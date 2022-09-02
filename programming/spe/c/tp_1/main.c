#include <stdio.h>
#include <stdlib.h>
#include "task.h"
#include "schedule.h"

int main(void) {
    int n;
    task* tasks = malloc(n * sizeof(task));
    scanf("%d\n", &n);
    for (int i = 0; i < n; i++) {
        int deadline;
        int penalty;
        int s = scanf("%d %d\n", &deadline, &penalty);
        tasks[i].id = i;
        tasks[i].start = -1;
        tasks[i].deadline = deadline;
        tasks[i].penalty = penalty;
    }
    schedule(tasks, n);
    print_schedule(tasks, n);
    free(tasks);
}
