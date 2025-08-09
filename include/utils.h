#ifndef UTILS_H
#define UTILS_H

#include <time.h>
#include <stddef.h>

// Timing utilities
typedef struct {
#ifdef _WIN32
    long long start;
    long long end;
#else
    struct timespec start;
    struct timespec end;
#endif
} Timer;

void timer_start(Timer *timer);
void timer_stop(Timer *timer);
double timer_elapsed_seconds(const Timer *timer);
double timer_elapsed_ms(const Timer *timer);

// Performance calculation utilities
double calculate_gflops(size_t n, double time_seconds);
void print_performance_header(void);
void print_performance_result(const char *method, size_t matrix_size, 
                             double time_ms, double gflops);

// Memory utilities
void* aligned_malloc(size_t size, size_t alignment);
void aligned_free(void *ptr);

// System information
void print_system_info(void);
size_t get_cache_size(int level);

// Random number generation
void seed_random(unsigned int seed);
double random_double(double min, double max);

#endif // UTILS_H
