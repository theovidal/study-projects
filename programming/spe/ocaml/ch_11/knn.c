#include <math.h>
#include <stdio.h>

struct point {
    float x;
    float y;
};

typedef struct point Point;

float distance2(Point A, Point B) {
    return powf(A.x - B.x, 2) + pow(A.y - B.y, 2);
}

int main(void) {

}
