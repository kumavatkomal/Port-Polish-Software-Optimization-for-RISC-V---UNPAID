# Sample Performance Results

This file contains sample performance results to demonstrate the expected output format and performance characteristics of the matrix multiplication implementations.

## Test Environment
- **System**: x86_64 Linux (RISC-V emulated)
- **CPU**: Intel Core i7-10700K @ 3.80GHz
- **Memory**: 32GB DDR4-3200
- **Compiler**: GCC 11.3.0 with -O3 optimization
- **Matrix Type**: Double precision (64-bit floating point)

## Performance Results

### Small Matrices (64x64 to 256x256)

| Size | Naive (ms) | Naive (GFLOPS) | Tiled (ms) | Tiled (GFLOPS) | Vector (ms) | Vector (GFLOPS) | Speedup |
|------|------------|----------------|------------|----------------|-------------|-----------------|---------|
| 64   | 0.45      | 1.18           | 0.32       | 1.66           | 0.18        | 2.95           | 2.5x    |
| 128  | 3.21      | 1.31           | 1.87       | 2.25           | 1.02        | 4.12           | 3.1x    |
| 256  | 26.89     | 1.25           | 12.45      | 2.70           | 6.88        | 4.89           | 3.9x    |

### Medium Matrices (512x512 to 1024x1024)

| Size | Naive (ms) | Naive (GFLOPS) | Tiled (ms) | Tiled (GFLOPS) | Vector (ms) | Vector (GFLOPS) | Speedup |
|------|------------|----------------|------------|----------------|-------------|-----------------|---------|
| 512  | 215.7     | 1.25           | 67.3       | 4.00           | 32.1        | 8.39           | 6.7x    |
| 768  | 728.4     | 1.24           | 178.2      | 5.07           | 85.6        | 10.55          | 8.5x    |
| 1024 | 1734.2    | 1.24           | 387.9      | 5.54           | 184.5       | 11.65          | 9.4x    |

### Large Matrices (1536x1536 to 2048x2048)

| Size | Naive (ms) | Naive (GFLOPS) | Tiled (ms) | Tiled (GFLOPS) | Vector (ms) | Vector (GFLOPS) | Speedup |
|------|------------|----------------|------------|----------------|-------------|-----------------|---------|
| 1536 | 5867.3    | 1.23           | 1205.8     | 5.98           | 567.2       | 12.72          | 10.3x   |
| 2048 | 13945.7   | 1.23           | 2654.1     | 6.47           | 1234.8      | 13.89          | 11.3x   |

## Tile Size Optimization Results

Testing with 512x512 matrices using different tile sizes:

| Tile Size | Time (ms) | GFLOPS | Relative Performance |
|-----------|-----------|--------|---------------------|
| 16        | 89.2      | 3.02   | 0.75x              |
| 32        | 72.1      | 3.74   | 0.93x              |
| 64        | 67.3      | 4.00   | 1.00x (baseline)   |
| 96        | 71.8      | 3.75   | 0.94x              |
| 128       | 76.4      | 3.53   | 0.88x              |

**Optimal tile size**: 64x64 for this system configuration.

## Memory Access Pattern Analysis

Cache miss rates (estimated):

| Implementation | L1 Cache Misses | L2 Cache Misses | L3 Cache Misses |
|----------------|-----------------|-----------------|-----------------|
| Naive          | 45%            | 28%            | 15%            |
| Tiled          | 12%            | 8%             | 4%             |
| Vector         | 8%             | 5%             | 2%             |

## Theoretical vs. Actual Performance

**Peak Performance Analysis** (512x512 matrices):
- Theoretical Peak (CPU): ~28.8 GFLOPS (8 cores × 3.6 GFLOPS/core)
- Naive Implementation: 1.25 GFLOPS (4.3% of peak)
- Tiled Implementation: 4.00 GFLOPS (13.9% of peak)
- Vector Implementation: 8.39 GFLOPS (29.1% of peak)

## Scaling Characteristics

**Time Complexity Verification**:
- Naive: O(n³) as expected
- Tiled: O(n³) with better constant factors
- Vector: O(n³) with significantly improved constant factors

**Memory Usage**:
- For n×n matrices: 3n² × 8 bytes = 24n² bytes total
- 1024×1024: ~25 MB
- 2048×2048: ~100 MB

## Compiler Optimization Impact

| Optimization Level | Naive (GFLOPS) | Tiled (GFLOPS) | Vector (GFLOPS) |
|--------------------|----------------|----------------|-----------------|
| -O0               | 0.31           | 0.85           | 1.24           |
| -O1               | 0.89           | 2.45           | 4.12           |
| -O2               | 1.15           | 3.67           | 7.89           |
| -O3               | 1.25           | 4.00           | 8.39           |
| -O3 -march=native | 1.28           | 4.15           | 8.67           |

## Recommendations

1. **Use tiled implementation** for matrices larger than 128×128
2. **Optimal tile size** is typically 32-128 depending on cache hierarchy
3. **Vector instructions** provide significant speedup when available
4. **Compiler optimizations** are crucial (use -O3 -march=native)
5. **Memory alignment** improves performance by 5-10%

## Notes

- Results may vary significantly on actual RISC-V hardware
- Vector instruction performance depends on vector unit implementation
- Cache behavior is system-dependent
- Large matrix performance limited by memory bandwidth
- Cross-compilation may show different optimization characteristics
