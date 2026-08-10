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

extern int png_image_write_to_file(png_image *, const char *, int, const void *, png_int_32, const void *);
extern void png_image_free(png_image *);

static void pixel(unsigned char *buffer, uint32_t width, uint32_t x, uint32_t y,
                  unsigned char red, unsigned char green, unsigned char blue) {
    size_t offset = ((size_t)y * width + x) * 4;
    buffer[offset] = red;
    buffer[offset + 1] = green;
    buffer[offset + 2] = blue;
    buffer[offset + 3] = 255;
}

int main(int argc, char **argv) {
    if (argc != 4) {
        fprintf(stderr, "usage: generate_photo_fixture width height output.png\n");
        return 2;
    }
    uint32_t width = (uint32_t)strtoul(argv[1], NULL, 10);
    uint32_t height = (uint32_t)strtoul(argv[2], NULL, 10);
    if (width == 0 || height == 0 || (uint64_t)width * height > 200000000ULL) {
        fprintf(stderr, "invalid dimensions\n");
        return 2;
    }

    size_t byte_count = (size_t)width * height * 4;
    unsigned char *buffer = malloc(byte_count);
    if (buffer == NULL) {
        fprintf(stderr, "cannot allocate fixture\n");
        return 1;
    }

    uint32_t border = (width < height ? width : height) / 30;
    if (border < 4) border = 4;
    for (uint32_t y = 0; y < height; ++y) {
        for (uint32_t x = 0; x < width; ++x) {
            unsigned char red = x < width / 2 ? 232 : 74;
            unsigned char green = y < height / 2 ? 184 : 104;
            unsigned char blue = x < width / 2 ? 72 : 184;
            if (x < border || y < border || x >= width - border || y >= height - border) {
                red = green = blue = 24;
            }
            if ((x > width / 2 - border / 2 && x < width / 2 + border / 2)
                || (y > height / 2 - border / 2 && y < height / 2 + border / 2)) {
                red = green = blue = 248;
            }
            pixel(buffer, width, x, y, red, green, blue);
        }
    }

    png_image image;
    memset(&image, 0, sizeof(image));
    image.version = 1;
    image.width = width;
    image.height = height;
    image.format = 3;
    if (!png_image_write_to_file(&image, argv[3], 0, buffer, 0, NULL)) {
        fprintf(stderr, "cannot encode PNG: %s\n", image.message);
        free(buffer);
        png_image_free(&image);
        return 1;
    }
    free(buffer);
    png_image_free(&image);
    return 0;
}
