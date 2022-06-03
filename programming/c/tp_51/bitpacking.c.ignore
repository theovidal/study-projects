#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>

const int BUFFER_WIDTH = 64;
const int BYTE_WIDTH = 8;
const uint64_t BYTE_MASK = (1 << BYTE_WIDTH) - 1;

struct bit_file {
    FILE *fp;
    uint64_t buffer;
    int buffer_length;
};

typedef struct bit_file bit_file;

bit_file *bin_initialize(FILE *fp){
    bit_file *bf = malloc(sizeof(bit_file));
    bf->fp = fp;
    bf->buffer = 0;
    bf->buffer_length = 0;
    return bf;
}

void bin_close(bit_file *bf){
    fclose(bf->fp);
    free(bf);
}

void output_bits(bit_file *bf, uint64_t data, int width, bool flush){
    assert(bf->buffer_length + width <= BUFFER_WIDTH);
    data &= (1 << width) - 1;
    bf->buffer |= (data << bf->buffer_length);
    bf->buffer_length += width;
    while (bf->buffer_length >= BYTE_WIDTH) {
        fputc(bf->buffer & BYTE_MASK, bf->fp);
        bf->buffer >>= BYTE_WIDTH;
        bf->buffer_length -= BYTE_WIDTH;
    }
    if (flush && bf->buffer_length > 0) {
        fputc(bf->buffer & BYTE_MASK, bf->fp);
        bf->buffer = 0;
        bf->buffer_length = 0;
    }
}

uint64_t input_bits(bit_file *bf, int width, bool *eof){
    int byte = 0;
    int offset = bf->buffer_length;
    while (byte != EOF && bf->buffer_length < width) {
        byte = getc(bf->fp);
        bf->buffer |= (byte & BYTE_MASK) << offset;
        bf->buffer_length += BYTE_WIDTH;
        offset += BYTE_WIDTH;
    }
    if (byte == EOF) {
        *eof = true;
        return 0;
    }
    uint64_t buffer_mask = (1 << width) - 1;
    uint64_t res = bf->buffer & buffer_mask;
    bf->buffer >>= width;
    bf->buffer_length -= width;
    return res;
}
