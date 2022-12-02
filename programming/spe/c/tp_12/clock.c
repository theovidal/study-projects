#include <time.h>

double delta_t(struct timespec t0, struct timespec t1){
    return (t1.tv_sec - t0.tv_sec) + 1e-9 * (t1.tv_nsec - t0.tv_nsec);
}

struct timespec gettime(void){
    struct timespec t;
    clock_gettime(CLOCK_REALTIME, &t);
    return t;
}
