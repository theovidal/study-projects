#ifndef CLOCK_H
#define CLOCK_H

#include <time.h>

typedef struct timespec timestamp;

timestamp gettime(void);

// Returns the elapsed (wall clock) time (in seconds) between the timestamps
double delta_t(timestamp t0, timestamp t1);


#endif
