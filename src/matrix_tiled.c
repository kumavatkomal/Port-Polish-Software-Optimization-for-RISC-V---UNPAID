#include "matrix.h"
#include "utils.h"
#include <stdlib.h>
#include <string.h>

// Cache-aware matrix multiplication using loop tiling/blocking
void matrix_mult_tiled(const Matrix *A, const Matrix *B, Matrix *C, size_t tile_size) {
    if (!A || !B || !C || !A->data || !B->data || !C->data) return;
    
    // Verify dimensions
    if (A->cols != B->rows || A->rows != C->rows || B->cols != C->cols) {
        return; // Invalid dimensions
    }
    
    size_t n = A->rows;
    size_t m = A->cols;
    size_t p = B->cols;
    
    // Initialize result matrix to zero
    matrix_init_zero(C);
    
    // Tiled matrix multiplication with blocking
    // This improves cache locality by working on smaller sub-matrices (tiles)
    // that fit better in cache
    
    for (size_t ii = 0; ii < n; ii += tile_size) {
        for (size_t jj = 0; jj < p; jj += tile_size) {
            for (size_t kk = 0; kk < m; kk += tile_size) {
                
                // Determine the actual tile boundaries
                size_t i_end = (ii + tile_size < n) ? ii + tile_size : n;
                size_t j_end = (jj + tile_size < p) ? jj + tile_size : p;
                size_t k_end = (kk + tile_size < m) ? kk + tile_size : m;
                
                // Perform multiplication on the current tile
                for (size_t i = ii; i < i_end; i++) {
                    for (size_t j = jj; j < j_end; j++) {
                        double sum = MATRIX_GET(C, i, j);
                        
                        // Inner loop unrolling for better performance
                        size_t k = kk;
                        for (; k < k_end - 3; k += 4) {
                            sum += MATRIX_GET(A, i, k)     * MATRIX_GET(B, k,     j);
                            sum += MATRIX_GET(A, i, k + 1) * MATRIX_GET(B, k + 1, j);
                            sum += MATRIX_GET(A, i, k + 2) * MATRIX_GET(B, k + 2, j);
                            sum += MATRIX_GET(A, i, k + 3) * MATRIX_GET(B, k + 3, j);
                        }
                        
                        // Handle remaining elements
                        for (; k < k_end; k++) {
                            sum += MATRIX_GET(A, i, k) * MATRIX_GET(B, k, j);
                        }
                        
                        MATRIX_SET(C, i, j, sum);
                    }
                }
            }
        }
    }
}

// Alternative implementation with better cache access pattern
void matrix_mult_tiled_optimized(const Matrix *A, const Matrix *B, Matrix *C, size_t tile_size) {
    if (!A || !B || !C || !A->data || !B->data || !C->data) return;
    
    // Verify dimensions
    if (A->cols != B->rows || A->rows != C->rows || B->cols != C->cols) {
        return; // Invalid dimensions
    }
    
    size_t n = A->rows;
    size_t m = A->cols;
    size_t p = B->cols;
    
    // Initialize result matrix to zero
    matrix_init_zero(C);
    
    // Optimized tiling with better memory access patterns
    // Use ikj loop order within tiles for better cache performance
    
    for (size_t ii = 0; ii < n; ii += tile_size) {
        for (size_t kk = 0; kk < m; kk += tile_size) {
            for (size_t jj = 0; jj < p; jj += tile_size) {
                
                // Determine the actual tile boundaries
                size_t i_end = (ii + tile_size < n) ? ii + tile_size : n;
                size_t k_end = (kk + tile_size < m) ? kk + tile_size : m;
                size_t j_end = (jj + tile_size < p) ? jj + tile_size : p;
                
                // ikj order within tile for better cache locality
                for (size_t i = ii; i < i_end; i++) {
                    for (size_t k = kk; k < k_end; k++) {
                        double a_ik = MATRIX_GET(A, i, k);
                        
                        // Vectorizable inner loop
                        for (size_t j = jj; j < j_end; j++) {
                            MATRIX_SET(C, i, j, 
                                      MATRIX_GET(C, i, j) + a_ik * MATRIX_GET(B, k, j));
                        }
                    }
                }
            }
        }
    }
}

// Function to determine optimal tile size based on cache size
size_t calculate_optimal_tile_size(size_t cache_size_bytes, size_t element_size) {
    // Rule of thumb: tile should fit 3 tiles (A, B, C sub-matrices) in cache
    // with some overhead for other data
    size_t usable_cache = cache_size_bytes / 4; // Conservative estimate
    size_t elements_per_tile = usable_cache / (3 * element_size);
    
    // Tile size is square root of elements per tile
    size_t tile_size = 1;
    while (tile_size * tile_size <= elements_per_tile) {
        tile_size++;
    }
    tile_size--; // Go back one step
    
    // Ensure tile size is at least 8 and at most 256
    if (tile_size < 8) tile_size = 8;
    if (tile_size > 256) tile_size = 256;
    
    // Round down to nearest power of 2 for better alignment
    size_t power_of_2 = 1;
    while (power_of_2 <= tile_size) {
        power_of_2 <<= 1;
    }
    power_of_2 >>= 1;
    
    return power_of_2;
}
