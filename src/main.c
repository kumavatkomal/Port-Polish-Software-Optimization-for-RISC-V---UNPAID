#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "matrix.h"
#include "utils.h"

// Default matrix size if not specified
#define DEFAULT_MATRIX_SIZE 512

// Tolerance for verification
#define VERIFICATION_TOLERANCE 1e-10

void print_usage(const char *program_name) {
    printf("Usage: %s [options] [matrix_size]\n", program_name);
    printf("Options:\n");
    printf("  -h, --help     Show this help message\n");
    printf("  -v, --verify   Verify results (slower for large matrices)\n");
    printf("  -t TILE_SIZE   Set tile size for cache-aware implementation\n");
    printf("\nArguments:\n");
    printf("  matrix_size    Size of square matrices (default: %d)\n", DEFAULT_MATRIX_SIZE);
    printf("\nExamples:\n");
    printf("  %s 1024        # Test with 1024x1024 matrices\n", program_name);
    printf("  %s -v 512      # Test with verification enabled\n", program_name);
    printf("  %s -t 32 256   # Use tile size 32 for 256x256 matrices\n", program_name);
}

int main(int argc, char *argv[]) {
    size_t matrix_size = DEFAULT_MATRIX_SIZE;
    size_t tile_size = DEFAULT_TILE_SIZE;
    int verify_results = 0;
    
    // Parse command line arguments
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        } else if (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "--verify") == 0) {
            verify_results = 1;
        } else if (strcmp(argv[i], "-t") == 0) {
            if (i + 1 < argc) {
                tile_size = (size_t)atoi(argv[++i]);
                if (tile_size == 0) {
                    fprintf(stderr, "Error: Invalid tile size\n");
                    return 1;
                }
            } else {
                fprintf(stderr, "Error: -t option requires a tile size\n");
                return 1;
            }
        } else {
            // Assume it's the matrix size
            matrix_size = (size_t)atoi(argv[i]);
            if (matrix_size == 0) {
                fprintf(stderr, "Error: Invalid matrix size\n");
                return 1;
            }
        }
    }
    
    // Validate parameters
    if (matrix_size < 2) {
        fprintf(stderr, "Error: Matrix size must be at least 2\n");
        return 1;
    }
    
    if (tile_size > matrix_size) {
        tile_size = matrix_size;
        printf("Warning: Tile size adjusted to matrix size (%zu)\n", tile_size);
    }
    
    printf("=== RISC-V Matrix Multiplication Performance Test ===\n\n");
    
    // Print system information
    print_system_info();
    
    printf("Configuration:\n");
    printf("  Matrix size: %zu x %zu\n", matrix_size, matrix_size);
    printf("  Tile size: %zu\n", tile_size);
    printf("  Verification: %s\n", verify_results ? "enabled" : "disabled");
    
#ifdef USE_VECTOR
    printf("  Vector instructions: enabled\n");
#else
    printf("  Vector instructions: disabled\n");
#endif
    
    printf("  Total operations: %.2f billion\n", 
           (double)(2.0 * matrix_size * matrix_size * matrix_size) / 1e9);
    printf("\n");
    
    // Allocate matrices
    printf("Allocating matrices...\n");
    Matrix *A = matrix_create(matrix_size, matrix_size);
    Matrix *B = matrix_create(matrix_size, matrix_size);
    Matrix *C_naive = matrix_create(matrix_size, matrix_size);
    Matrix *C_tiled = matrix_create(matrix_size, matrix_size);
    
    if (!A || !B || !C_naive || !C_tiled) {
        fprintf(stderr, "Error: Failed to allocate matrices\n");
        return 1;
    }
    
#ifdef USE_VECTOR
    Matrix *C_vector = matrix_create(matrix_size, matrix_size);
    if (!C_vector) {
        fprintf(stderr, "Error: Failed to allocate vector result matrix\n");
        return 1;
    }
#endif
    
    // Initialize matrices with random data
    printf("Initializing matrices with random data...\n");
    seed_random(42); // Fixed seed for reproducible results
    matrix_init_random(A, -1.0, 1.0);
    matrix_init_random(B, -1.0, 1.0);
    
    printf("\nStarting performance tests...\n");
    print_performance_header();
    
    Timer timer;
    double time_ms, gflops;
    
    // Test 1: Naive implementation
    printf("Running naive implementation...\n");
    matrix_init_zero(C_naive);
    timer_start(&timer);
    matrix_mult_naive(A, B, C_naive);
    timer_stop(&timer);
    
    time_ms = timer_elapsed_ms(&timer);
    gflops = calculate_gflops(matrix_size, timer_elapsed_seconds(&timer));
    print_performance_result("Naive", matrix_size, time_ms, gflops);
    
    // Test 2: Cache-aware tiled implementation
    printf("Running cache-aware tiled implementation...\n");
    matrix_init_zero(C_tiled);
    timer_start(&timer);
    matrix_mult_tiled(A, B, C_tiled, tile_size);
    timer_stop(&timer);
    
    time_ms = timer_elapsed_ms(&timer);
    gflops = calculate_gflops(matrix_size, timer_elapsed_seconds(&timer));
    print_performance_result("Tiled", matrix_size, time_ms, gflops);
    
#ifdef USE_VECTOR
    // Test 3: Vector implementation
    printf("Running vector implementation...\n");
    matrix_init_zero(C_vector);
    timer_start(&timer);
    matrix_mult_vector(A, B, C_vector);
    timer_stop(&timer);
    
    time_ms = timer_elapsed_ms(&timer);
    gflops = calculate_gflops(matrix_size, timer_elapsed_seconds(&timer));
    print_performance_result("Vector", matrix_size, time_ms, gflops);
#endif
    
    // Verification
    if (verify_results) {
        printf("\nVerifying results...\n");
        
        if (matrix_verify(C_naive, C_tiled, VERIFICATION_TOLERANCE)) {
            printf("✓ Naive and tiled results match\n");
        } else {
            printf("✗ Naive and tiled results differ!\n");
        }
        
#ifdef USE_VECTOR
        if (matrix_verify(C_naive, C_vector, VERIFICATION_TOLERANCE)) {
            printf("✓ Naive and vector results match\n");
        } else {
            printf("✗ Naive and vector results differ!\n");
        }
#endif
    }
    
    // Calculate speedups
    printf("\nPerformance Summary:\n");
    // Additional analysis would go here
    
    // Cleanup
    matrix_destroy(A);
    matrix_destroy(B);
    matrix_destroy(C_naive);
    matrix_destroy(C_tiled);
    
#ifdef USE_VECTOR
    matrix_destroy(C_vector);
#endif
    
    printf("\nTest completed successfully!\n");
    return 0;
}
