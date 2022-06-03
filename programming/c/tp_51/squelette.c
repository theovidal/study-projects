#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>
#include <inttypes.h>

#include "stack.h"

typedef uint32_t cw_t;
typedef uint8_t byte_t;

#define CW_MAX_WIDTH 16
#define DICTFULL (1u << CW_MAX_WIDTH)

const cw_t NO_ENTRY = DICTFULL;
const cw_t NULL_CW = DICTFULL;
const cw_t FIRST_CW = 0x100;
const int CW_MIN_WIDTH = 9;

int VERBOSITY = 0;

struct dict_entry_t {
    cw_t pointer;
    uint8_t byte;
};

typedef struct dict_entry_t dict_entry_t;

struct dict_t {
    cw_t next_available_cw;
    int cw_width;
    dict_entry_t data[DICTFULL];
};

struct dict_t dict;

cw_t inverse_table[DICTFULL][256];

void initialize_dictionary(void) {
    dict.next_available_cw = 256;
    dict.cw_width = CW_MIN_WIDTH;
    for (int i = 0; i < 256; i++) {
        dict.data[i].pointer = NULL_CW;
        dict.data[i].byte = i;
    }
}

cw_t lookup(cw_t cw, byte_t t) {
    cw_t candidate = inverse_table[cw][t];
    if (candidate >= dict.next_available_cw) return NO_ENTRY;

    dict_entry_t inv = dict.data[candidate];
    if (inv.pointer == cw && inv.byte == t) return candidate;
    else return NO_ENTRY;
}

void build_entry(cw_t cw, byte_t byte) {
    if (dict.next_available_cw == DICTFULL) return;

    dict_entry_t entry;
    entry.pointer = cw;
    entry.byte = byte;
    dict.data[dict.next_available_cw] = entry;
    inverse_table[cw][byte] = dict.next_available_cw;

    dict.next_available_cw++;
}

void mock_compress(FILE* input_file, FILE* output_file) {
    initialize_dictionary();
    int x = getc(input_file); // D'abord en int! si directement byte_t, on n'aura pas de EOF
    cw_t m = NULL_CW;
    while (x != EOF) {
        if (m == NULL_CW) m = x;
        else {
            cw_t c = lookup(m, (byte_t)x);
            if (c == NO_ENTRY) {
                fprintf(output_file, "%d ", m);
                build_entry(m, x);
                m = (cw_t)x;
            } else {
                m = c; // le dictionnaire marche avec un couple (code, byte) !!
            }
        }
        x = getc(input_file);
    }
    fprintf(output_file, "%d", m);
}

// ––––––––––––––– //
//  Décompression  //
// ––––––––––––––– //

byte_t decode_cw(FILE* fp, cw_t cw, stack* s) {
    dict_entry_t entry = dict.data[cw];
    while (entry.pointer != NULL_CW) {
        stack_push(s, entry.byte);
        entry = dict.data[entry.pointer];
    }
    stack_push(s, entry.byte);

    while (stack_size(s) > 0) {
        putc(stack_pop(s), fp);
    }
    return entry.byte;
}

byte_t get_first_byte(cw_t cw) {
    dict_entry_t entry = dict.data[cw];
    while (entry.pointer != NULL_CW) {
        entry = dict.data[entry.pointer];
    }
    return entry.byte;
}

void mock_decompress(FILE* input_file, FILE* output_file) {
    initialize_dictionary();
    stack* s = stack_new(DICTFULL);
    cw_t n;
    cw_t last = n;
    if (fscanf(input_file, "%d", &last)) decode_cw(output_file, last, s); // traiter le premier lu (et vérifier qu'il existe bien sûr)
    while (fscanf(input_file, "%d", &n) == 1) {
        if (n == dict.next_available_cw) {
            byte_t x = get_first_byte(last);
            build_entry(last, x);
            decode_cw(output_file, n, s); // Désormais, le code de n est créé grâce au build_entry!
        } else {
            byte_t x = decode_cw(output_file, n, s);
            build_entry(last, x);
        }

        last = n;
    }
    stack_free(s);
}

// ––––––––––––––––––––––––––––– //
//  Lecture et écriture binaire  //
// ––––––––––––––––––––––––––––– //

#define BUFFER_WIDTH 64
#define BYTE_WIDTH 8
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

void output_bits(bit_file* bf, uint64_t data, int width, bool flush) {
    data &= (1 << width) - 1;
    bf->buffer |= (data << bf->buffer_length);
    bf->buffer_length += width;
    while (bf->buffer_length >= BYTE_WIDTH) {
        putc(bf->buffer & BYTE_MASK, bf->fp); // Pour simplifier, on définit les constantes BYTE_WIDTH et BYTE_MASK (ce dernier récupère les 8 premiers bits)
        bf->buffer >>= BYTE_WIDTH;
        bf->buffer_length -= BYTE_WIDTH;
    }
    if (flush && bf->buffer_length != 0) {
        putc(bf->buffer & BYTE_MASK, bf->fp);
        bf->buffer = 0;
        bf->buffer_length = 0;
    }
}

uint64_t input_bits(bit_file* bf, int width, bool* eof) {
    int b = getc(bf->fp);
    int offset = bf->buffer_length;
    while (b != EOF && bf->buffer_length - offset < width) {
        bf->buffer = (bf->buffer << BYTE_WIDTH) | (byte_t)b;
        bf->buffer_length += BYTE_WIDTH;
        b = getc(bf->fp);
    }
    if (b == EOF) *eof = 1;
    return bf->buffer & ((1 << width) - 1);
}

void compress(FILE* input_file, FILE* output_file) {};
void decompress(FILE* input_file, FILE* output_file) {};

int main(int argc, char* argv[]){
    if (argc < 2) {
        printf("Il faut choisir un mode : c, C, d, D");
        return -1;
    }
    FILE* in = stdin;
    FILE* out = stdout;
    if (argc > 2) in = fopen(argv[2], "r");
    if (argc > 3) out = fopen(argv[3], "w");

    char* mode = argv[1];
    switch (mode[0]) {
        case 'c':
            compress(in, out);
            break;
        case 'C':
            mock_compress(in, out);
            break;
        case 'd':
            decompress(in, out);
            break;
        case 'D':
            mock_decompress(in, out);
            break;

        default:
            printf("Mode invalide. Merci de choisir entre : c, C, d, D");
    }
    return EXIT_SUCCESS;
}
