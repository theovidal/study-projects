#ifndef BITPACKING_H
#define BITPACKING_H

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

struct bit_file {
    FILE *fp;
    uint64_t buffer;
    int buffer_length;
};

typedef struct bit_file bit_file;

bit_file *bin_initialize(FILE *fp);

void bin_close(bit_file *bf);

void output_bits(bit_file *bf, uint64_t data, int width, bool flush);

uint64_t input_bits(bit_file *bf, int width, bool *eof);

#endif
