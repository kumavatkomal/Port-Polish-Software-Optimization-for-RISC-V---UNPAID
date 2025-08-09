#include "matrix.h"
#include "utils.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Matrix allocation and initialization
Matrix* matrix_create(size_t rows, size_t cols) {
    Matrix *mat = malloc(sizeof(Matrix));
    if (!mat) return NULL;
    
    // Allocate aligned memory for better cache performance
    mat->data = (double*)aligned_malloc(rows * cols * sizeof(double), 32);
    if (!mat->data) {
        free(mat);
        return NULL;
    }
    
    mat->rows = rows;
    mat->cols = cols;
    return mat;
}

void matrix_destroy(Matrix *mat) {
    if (mat) {
        if (mat->data) {
            aligned_free(mat->data);
        }
        free(mat);
    }
}

void matrix_init_random(Matrix *mat, double min, double max) {
    if (!mat || !mat->data) return;
    
    for (size_t i = 0; i < mat->rows * mat->cols; i++) {
        mat->data[i] = random_double(min, max);
    }
}

void matrix_init_zero(Matrix *mat) {
    if (!mat || !mat->data) return;
    memset(mat->data, 0, mat->rows * mat->cols * sizeof(double));
}

// Naive matrix multiplication implementation
void matrix_mult_naive(const Matrix *A, const Matrix *B, Matrix *C) {
    if (!A || !B || !C || !A->data || !B->data || !C->data) return;
    
    // Verify dimensions
    if (A->cols != B->rows || A->rows != C->rows || B->cols != C->cols) {
        return; // Invalid dimensions
    }
    
    size_t n = A->rows;
    size_t m = A->cols;
    size_t p = B->cols;
    
    // Simple triple-nested loop implementation
    // This is the most basic approach with poor cache locality
    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < p; j++) {
            double sum = 0.0;
            for (size_t k = 0; k < m; k++) {
                sum += MATRIX_GET(A, i, k) * MATRIX_GET(B, k, j);
            }
            MATRIX_SET(C, i, j, sum);
        }
    }
}

// Matrix verification function
int matrix_verify(const Matrix *A, const Matrix *B, double tolerance) {
    if (!A || !B || !A->data || !B->data) return 0;
    if (A->rows != B->rows || A->cols != B->cols) return 0;
    
    for (size_t i = 0; i < A->rows * A->cols; i++) {
        double diff = fabs(A->data[i] - B->data[i]);
        if (diff > tolerance) {
            return 0; // Matrices differ
        }
    }
    
    return 1; // Matrices match within tolerance
}
