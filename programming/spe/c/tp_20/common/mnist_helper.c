#include "mnist_helper.h"

typedef char __attribute__((vector_size(4 * sizeof(char)))) mnist_raw_vec;

static unsigned int mnist_bin_to_int(mnist_raw_vec v)
{
    int i;
    unsigned int ret = 0;

    for (i = 0; i < 4; ++i)
    {
        ret <<= 8;
        ret |= (unsigned char)v[i];
    }

    return ret;
}

int parse_mnist(char *image_dataset_path, char *label_dataset_path, mnist_dataset_t *parsed_dataset)
{
    int return_code = 0;
    FILE *img_fp = NULL;
    FILE *lab_fp = NULL;

    img_fp = fopen(image_dataset_path, "rb");
    if (!img_fp)
    {
        fprintf(stderr, "Cannot open image dataset with path:\n%s\n", image_dataset_path);
        return_code = -1;
        goto cleanup;
    }

    lab_fp = fopen(label_dataset_path, "rb");
    if (!lab_fp)
    {
        fprintf(stderr, "Cannot open picture dataset with path:\n%s\n", label_dataset_path);
        return_code = -2;
        goto cleanup;
    }

    mnist_raw_vec tmp_buffer;

    // Dumping headers' code (don't know how to process them)
    fread(&tmp_buffer, sizeof(char), 4, img_fp);
    fread(&tmp_buffer, sizeof(char), 4, lab_fp);

    // Reading number of entries
    size_t img_num, lab_num;

    fread(&tmp_buffer, sizeof(char), 4, img_fp);
    img_num = mnist_bin_to_int(tmp_buffer);

    fread(&tmp_buffer, sizeof(char), 4, lab_fp);
    lab_num = mnist_bin_to_int(tmp_buffer);

    if (lab_num != img_num)
    {
        fprintf(stderr, "Number of images is different from number of labels:\n%lu VS %lu\n", img_num, lab_num);
        return_code = -3;
        goto cleanup;
    }
    parsed_dataset->case_num = img_num;

    // Reading images' dimensions
    size_t height, width;

    fread(&tmp_buffer, sizeof(char), 4, img_fp);
    height = mnist_bin_to_int(tmp_buffer);
    fread(&tmp_buffer, sizeof(char), 4, img_fp);
    width = mnist_bin_to_int(tmp_buffer);

    parsed_dataset->height = height;
    parsed_dataset->width = width;

    // Reading content
    parsed_dataset->cases = (mnist_case_t *)malloc(sizeof(mnist_case_t) * img_num);
    parsed_dataset->min_label = INT_MAX;
    parsed_dataset->max_label = INT_MIN;

    for (size_t i = 0; i < img_num; i++)
    {
        parsed_dataset->cases[i].picture = (int *)malloc(sizeof(int) * width * height);
        char data_buffer[width * height];
        char label_buffer;

        size_t data_read = fread(data_buffer, sizeof(char), width * height, img_fp);

        if (data_read < width * height)
        {
            fprintf(stderr, "Warning: read %lu when expecting %lu\n", data_read, width * height);
        }
        // Copy buffer into the output structure (implicitly convert char to int
        // but taking char as unsigned first)
        for (size_t j = 0; j < data_read; j++)
        {
            parsed_dataset->cases[i].picture[j] = (unsigned char)data_buffer[j];
        }

        // Read associated label
        fread(&label_buffer, sizeof(char), 1, lab_fp);
        parsed_dataset->cases[i].label = label_buffer;

        if ((int)label_buffer < parsed_dataset->min_label)
            parsed_dataset->min_label = label_buffer;

        if ((int)label_buffer > parsed_dataset->max_label)
            parsed_dataset->max_label = label_buffer;
    }

cleanup:
    if (img_fp)
        fclose(img_fp);
    if (lab_fp)
        fclose(lab_fp);

    return return_code;
}

void free_mnist_dataset(mnist_dataset_t *dataset)
{
    for (size_t i = 0; i < dataset->case_num; i++)
    {
        free(dataset->cases[i].picture);
    }
    free(dataset->cases);
    dataset->cases = 0;
}

void fprint_raw_mnist_pic(FILE *f, mnist_case_t *c, size_t height, size_t width)
{
    fprintf(f, "Label: %d\n\nPicture:\n\n", c->label);

    size_t a_index = 0;

    for (size_t i = 0; i < height; i++)
    {
        fprintf(f, "\t");
        for (size_t j = 0; j < width - 1; j++)
        {
            fprintf(f, "%3d ", c->picture[a_index]);
            a_index++;
        }
        fprintf(f, "%3d \n", c->picture[a_index]);
        a_index++;
    }
    fprintf(f, "\n\n");
}

#define COLOR_RESET "\x1b[0m"
#define COLOR_RGB_FG_FMT "\x1b[38;2;%3u;%3u;%3um"
#define COLOR_RGB_BG_FMT "\x1b[48;2;%3u;%3u;%3um"

#define FPRINT_GREY_SQUARE(f, grey) \
    fprintf((f), COLOR_RGB_FG_FMT COLOR_RGB_BG_FMT "  " COLOR_RESET, (grey), (grey), (grey), (grey), (grey), (grey))
/*
static void hsv_to_rgb(char *r, char *g, char *b, int h, double s, double v)
{
    int hi = (h / 60) % 6;
    double f = ((double)h) / 60 - (double)hi;

    double l = v * (1 - s);
    double m = v * (1 - f * s);
    double n = v * (1 - (1 - f) * s);

    double r_d, g_d, b_d;
    switch (hi)
    {
    case 0:
        r_d = v;
        g_d = n;
        b_d = l;
        break;

    case 1:
        r_d = m;
        g_d = v;
        b_d = l;
        break;

    case 2:
        r_d = l;
        g_d = v;
        b_d = n;
        break;

    case 3:
        r_d = l;
        g_d = m;
        b_d = v;
        break;

    case 4:
        r_d = n;
        g_d = l;
        b_d = v;
        break;

    case 5:
        r_d = v;
        g_d = l;
        b_d = m;
        break;

    default:
        abort();
        break;
    }

    *r = 255 * r_d;
    *g = 255 * g_d;
    *b = 255 * b_d;

    fprintf(stderr, "Input: (%d, %f, %f)\nOutput: (%X, %X, %X)\n", h, s, v, *r, *g, *b);
}

#define FPRINTF_BLUESCALE(f, scale)                \
    {                                              \
        char r, g, b;                              \
        hsv_to_rgb(&r, &g, &b, (scale)*360, 1, 1); \
        fprintf(f, COLOR_RGB_BG_FMT, r, g, b);     \
    }
*/
void fprint_pretty_mnist_pic(FILE *f, mnist_case_t *c, size_t height, size_t width)
{
    fprintf(f, "Label: %d\n\nPicture:\n\n", c->label);

    size_t a_index = 0;

    for (size_t i = 0; i < height; i++)
    {
        fprintf(f, "\t");
        for (size_t j = 0; j < width - 1; j++)
        {
            FPRINT_GREY_SQUARE(f, (unsigned)(255 - c->picture[a_index]));
            a_index++;
        }
        FPRINT_GREY_SQUARE(f, (unsigned)(255 - c->picture[a_index]));
        fprintf(f, "\n");
        a_index++;
    }
    fprintf(f, "\n\n");
}

void fprint_confusion_matrix(FILE *f, double *matrix, mnist_label_t min_label, mnist_label_t max_label)
{
    fprintf(f, "Confusion matrix: \n\n");

    mnist_label_t labels = max_label - min_label + 1;
    // Header line
    fprintf(f, "    ");
    for (mnist_label_t i = 0; i < labels; i++)
    {
        fprintf(f, " %3d  ", i + min_label);
    }
    fprintf(f, "\n");
    // Matrix line
    for (mnist_label_t i = 0; i < labels; i++)
    {
        fprintf(f, "%2d |", i + min_label);
        for (mnist_label_t j = 0; j < labels; j++)
        {
            fprintf(f, COLOR_RGB_BG_FMT, (unsigned)(255 * (matrix[i * labels + j] + 0.55) / 1.55),
                    (unsigned)(255 * (matrix[i * labels + j] + 0.55) / 1.55),
                    (unsigned)(255 * (matrix[i * labels + j] + 0.55) / 1.55));

            // FPRINTF_BLUESCALE(f, matrix[i * labels + j]);
            fprintf(f, " %1.2f " COLOR_RESET, matrix[i * labels + j]);
        }
        fprintf(f, " " COLOR_RESET "\n");
    }
    fprintf(f, "\n" COLOR_RESET "\n");
}
