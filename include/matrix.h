#ifndef MATRIX_H
#define MATRIX_H

#include <stddef.h>

// Matrix structure
typedef struct {
    double *data;
    size_t rows;
    size_t cols;
} Matrix;

// Matrix allocation and deallocation
Matrix* matrix_create(size_t rows, size_t cols);
void matrix_destroy(Matrix *mat);
void matrix_init_random(Matrix *mat, double min, double max);
void matrix_init_zero(Matrix *mat);

// Matrix access macros
#define MATRIX_GET(mat, i, j) ((mat)->data[(i) * (mat)->cols + (j)])
#define MATRIX_SET(mat, i, j, val) ((mat)->data[(i) * (mat)->cols + (j)] = (val))

// Matrix multiplication implementations
void matrix_mult_naive(const Matrix *A, const Matrix *B, Matrix *C);
void matrix_mult_tiled(const Matrix *A, const Matrix *B, Matrix *C, size_t tile_size);

#ifdef USE_VECTOR
void matrix_mult_vector(const Matrix *A, const Matrix *B, Matrix *C);
#endif

// Verification function
int matrix_verify(const Matrix *A, const Matrix *B, double tolerance);

// Default tile size for cache-aware implementation
#define DEFAULT_TILE_SIZE 64

#endif // MATRIX_H
