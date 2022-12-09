CC = gcc
CFLAGS = -Wall -Wextra -O3 -march=native -pthread -flto
SRCS := $(wildcard *.c)
OBJECTS := $(SRCS:%.c=%.o)

debug: CFLAGS += -fsanitize=thread -Og -g

.PHONY: clean debug release run


debug: $(OBJECTS)
	${CC} ${CFLAGS} -o qsort.out $^


release: $(OBJECTS)
	${CC} ${CFLAGS} -o qsort.out $^

%.o: %.c
	${CC} ${CFLAGS} -c $< -o $@

clean:
	rm -f qsort.out *.o

run:
	./qsort.out
