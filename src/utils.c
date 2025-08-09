#include "utils.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#ifdef _WIN32
#include <windows.h>
#include <malloc.h>
#else
#include <sys/time.h>
#include <unistd.h>
#include <sys/sysinfo.h>
#endif

// Timer functions
void timer_start(Timer *timer) {
#ifdef _WIN32
    QueryPerformanceCounter((LARGE_INTEGER*)&timer->start);
#else
    clock_gettime(CLOCK_MONOTONIC, &timer->start);
#endif
}

void timer_stop(Timer *timer) {
#ifdef _WIN32
    QueryPerformanceCounter((LARGE_INTEGER*)&timer->end);
#else
    clock_gettime(CLOCK_MONOTONIC, &timer->end);
#endif
}

double timer_elapsed_seconds(const Timer *timer) {
#ifdef _WIN32
    LARGE_INTEGER frequency;
    QueryPerformanceFrequency(&frequency);
    return (double)(timer->end - timer->start) / frequency.QuadPart;
#else
    double start_sec = timer->start.tv_sec + timer->start.tv_nsec / 1e9;
    double end_sec = timer->end.tv_sec + timer->end.tv_nsec / 1e9;
    return end_sec - start_sec;
#endif
}

double timer_elapsed_ms(const Timer *timer) {
    return timer_elapsed_seconds(timer) * 1000.0;
}

// Performance calculation
double calculate_gflops(size_t n, double time_seconds) {
    // Matrix multiplication: 2*n^3 - n^2 operations
    double operations = 2.0 * n * n * n - n * n;
    return operations / (time_seconds * 1e9);
}

void print_performance_header(void) {
    printf("\n");
    printf("%-12s %-10s %-12s %-10s\n", "Method", "Size", "Time (ms)", "GFLOPS");
    printf("%-12s %-10s %-12s %-10s\n", "------", "----", "---------", "------");
}

void print_performance_result(const char *method, size_t matrix_size, 
                             double time_ms, double gflops) {
    printf("%-12s %-10zu %-12.2f %-10.2f\n", method, matrix_size, time_ms, gflops);
}

// Memory utilities
void* aligned_malloc(size_t size, size_t alignment) {
#ifdef _WIN32
    return _aligned_malloc(size, alignment);
#else
    void *ptr;
    if (posix_memalign(&ptr, alignment, size) != 0) {
        return NULL;
    }
    return ptr;
#endif
}

void aligned_free(void *ptr) {
#ifdef _WIN32
    _aligned_free(ptr);
#else
    free(ptr);
#endif
}

// System information
void print_system_info(void) {
    printf("System Information:\n");
    
#ifdef _WIN32
    SYSTEM_INFO si;
    GetSystemInfo(&si);
    printf("  Processors: %lu\n", si.dwNumberOfProcessors);
    printf("  Page size: %lu bytes\n", si.dwPageSize);
    
    MEMORYSTATUSEX ms;
    ms.dwLength = sizeof(ms);
    if (GlobalMemoryStatusEx(&ms)) {
        printf("  Total memory: %.1f GB\n", ms.ullTotalPhys / (1024.0 * 1024.0 * 1024.0));
        printf("  Available memory: %.1f GB\n", ms.ullAvailPhys / (1024.0 * 1024.0 * 1024.0));
    }
#else
    long nprocs = sysconf(_SC_NPROCESSORS_ONLN);
    if (nprocs > 0) {
        printf("  Processors: %ld\n", nprocs);
    }
    
    long page_size = sysconf(_SC_PAGESIZE);
    if (page_size > 0) {
        printf("  Page size: %ld bytes\n", page_size);
    }
    
    struct sysinfo si;
    if (sysinfo(&si) == 0) {
        printf("  Total memory: %.1f GB\n", si.totalram * si.mem_unit / (1024.0 * 1024.0 * 1024.0));
        printf("  Available memory: %.1f GB\n", si.freeram * si.mem_unit / (1024.0 * 1024.0 * 1024.0));
    }
#endif

    printf("  Architecture: RISC-V (emulated/cross-compiled)\n");
    
#ifdef USE_VECTOR
    printf("  Vector extensions: enabled\n");
#else
    printf("  Vector extensions: disabled\n");
#endif
    
    printf("\n");
}

size_t get_cache_size(int level) {
    // This is a simplified implementation
    // In a real RISC-V system, you would read from hardware registers
    // or system files to get actual cache sizes
    switch (level) {
        case 1: return 32 * 1024;     // 32KB L1 cache
        case 2: return 256 * 1024;    // 256KB L2 cache
        case 3: return 2 * 1024 * 1024; // 2MB L3 cache
        default: return 0;
    }
}

// Random number generation
static unsigned int random_seed = 1;

void seed_random(unsigned int seed) {
    random_seed = seed;
}

double random_double(double min, double max) {
    // Simple linear congruential generator
    random_seed = random_seed * 1103515245 + 12345;
    double r = (double)(random_seed & 0x7FFFFFFF) / 0x7FFFFFFF;
    return min + r * (max - min);
}
