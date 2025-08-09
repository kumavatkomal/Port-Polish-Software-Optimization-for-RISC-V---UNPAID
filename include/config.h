#ifndef CONFIG_H
#define CONFIG_H

// Project configuration and compile-time options

// Version information
#define PROJECT_NAME "RISC-V Matrix Multiplication Performance Test"
#define PROJECT_VERSION "1.0.0"
#define PROJECT_AUTHOR "Port & Polish Optimization Challenge"

// Performance configuration
#define MAX_MATRIX_SIZE 4096
#define MIN_MATRIX_SIZE 2
#define CACHE_LINE_SIZE 64
#define MEMORY_ALIGNMENT 32

// Timing configuration
#define WARMUP_ITERATIONS 3
#define BENCHMARK_ITERATIONS 5

// Vector configuration
#ifdef USE_VECTOR
    #define VECTOR_ENABLED 1
    #define VECTOR_LENGTH 8  // Simulated vector length
#else
    #define VECTOR_ENABLED 0
#endif

// Debug configuration
#ifdef DEBUG
    #define DEBUG_ENABLED 1
    #define DEBUG_PRINT(fmt, ...) printf("[DEBUG] " fmt "\n", ##__VA_ARGS__)
#else
    #define DEBUG_ENABLED 0
    #define DEBUG_PRINT(fmt, ...) do {} while(0)
#endif

// Optimization hints for compiler
#define LIKELY(x)   __builtin_expect(!!(x), 1)
#define UNLIKELY(x) __builtin_expect(!!(x), 0)
#define PREFETCH(addr) __builtin_prefetch(addr, 0, 3)

// Cache size hints (typical RISC-V values)
#define L1_CACHE_SIZE (32 * 1024)    // 32KB
#define L2_CACHE_SIZE (256 * 1024)   // 256KB
#define L3_CACHE_SIZE (2 * 1024 * 1024) // 2MB

#endif // CONFIG_H
