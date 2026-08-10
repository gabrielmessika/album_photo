#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef uint32_t png_uint_32;
typedef int32_t png_int_32;

typedef struct png_image {
    void *opaque;
    png_uint_32 version;
    png_uint_32 width;
    png_uint_32 height;
    png_uint_32 format;
    png_uint_32 flags;
    png_uint_32 colormap_entries;
    png_uint_32 warning_or_error;
    char message[64];
} png_image;

extern int png_image_begin_read_from_file(png_image *, const char *);
extern int png_image_finish_read(png_image *, const void *, void *, png_int_32, void *);
extern int png_image_write_to_file(png_image *, const char *, int, const void *, png_int_32, const void *);
extern void png_image_free(png_image *);

enum {
    PNG_IMAGE_VERSION = 1,
    PNG_FORMAT_RGBA = 3
};

static void fail(const char *message, const png_image *image) {
    if (image != NULL && image->message[0] != '\0') {
        fprintf(stderr, "%s: %s\n", message, image->message);
    } else {
        fprintf(stderr, "%s\n", message);
    }
    exit(1);
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "usage: normalize_png_4x5 input.png output.png\n");
        return 2;
    }

    png_image input;
    memset(&input, 0, sizeof(input));
    input.version = PNG_IMAGE_VERSION;
    if (!png_image_begin_read_from_file(&input, argv[1])) {
        fail("cannot read PNG header", &input);
    }
    if (input.width < 4 || input.height < 5) {
        fail("image is too small", &input);
    }

    png_uint_32 output_width = input.width - (input.width % 4);
    png_uint_32 output_height = output_width * 5 / 4;
    if (output_height > input.height) {
        output_height = input.height - (input.height % 5);
        output_width = output_height * 4 / 5;
    }

    input.format = PNG_FORMAT_RGBA;
    size_t input_bytes = (size_t)input.width * input.height * 4;
    unsigned char *input_pixels = malloc(input_bytes);
    if (input_pixels == NULL) {
        fail("cannot allocate input buffer", &input);
    }
    if (!png_image_finish_read(&input, NULL, input_pixels, 0, NULL)) {
        free(input_pixels);
        fail("cannot decode PNG", &input);
    }

    size_t output_bytes = (size_t)output_width * output_height * 4;
    unsigned char *output_pixels = malloc(output_bytes);
    if (output_pixels == NULL) {
        free(input_pixels);
        fail("cannot allocate output buffer", &input);
    }

    png_uint_32 left = (input.width - output_width) / 2;
    png_uint_32 top = (input.height - output_height) / 2;
    for (png_uint_32 y = 0; y < output_height; ++y) {
        const unsigned char *source = input_pixels + (((size_t)(y + top) * input.width + left) * 4);
        unsigned char *destination = output_pixels + ((size_t)y * output_width * 4);
        memcpy(destination, source, (size_t)output_width * 4);
    }

    png_image output;
    memset(&output, 0, sizeof(output));
    output.version = PNG_IMAGE_VERSION;
    output.width = output_width;
    output.height = output_height;
    output.format = PNG_FORMAT_RGBA;
    if (!png_image_write_to_file(&output, argv[2], 0, output_pixels, 0, NULL)) {
        free(output_pixels);
        free(input_pixels);
        png_image_free(&input);
        fail("cannot encode PNG", &output);
    }

    free(output_pixels);
    free(input_pixels);
    png_image_free(&input);
    png_image_free(&output);
    return 0;
}
