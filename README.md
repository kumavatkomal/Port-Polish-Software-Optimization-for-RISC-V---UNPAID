# Port & Polish: Software Optimization for RISC-V

## Matrix Multiplication Performance Optimization

This project implements matrix multiplication using different optimization techniques and measures their performance on RISC-V architecture.

## Features

- **Naive Matrix Multiplication**: Basic O(n³) implementation
- **Cache-Aware Implementation**: Loop tiling/blocking for better cache performance
- **Vector Instructions Support**: Conditional compilation for RISC-V vector extensions
- **Performance Benchmarking**: Comprehensive timing and performance analysis
- **Configurable Matrix Sizes**: Test with different matrix dimensions

## Building and Running

### Prerequisites
- GCC with RISC-V support
- Make

### Build Options

#### Standard Build (without vector instructions)
```bash
make
```

#### Build with Vector Instructions
```bash
make VECTOR=1
```

#### Build with Debug Information
```bash
make DEBUG=1
```

#### Clean Build
```bash
make clean
```

### Running
```bash
./matrix_mult [matrix_size]
```

Example:
```bash
./matrix_mult 512
```

## Implementation Details

### Naive Approach
- Simple triple-nested loop
- Direct element-by-element computation
- No optimization for cache locality

### Cache-Aware Approach (Loop Tiling)
- Divides matrices into smaller blocks
- Improves cache locality by working on tiles
- Configurable tile size for optimal performance

### Vector Instructions
- Uses RISC-V vector extensions when available
- Conditional compilation via preprocessor flags
- Fallback to scalar operations when vectors not available

## Performance Metrics

The program measures and reports:
- Execution time for each approach
- GFLOPS (Giga Floating Point Operations Per Second)
- Cache miss ratios (when supported)
- Speedup comparison between methods

## Project Structure

```
├── src/
│   ├── main.c              # Main program and benchmarking
│   ├── matrix_naive.c      # Naive implementation
│   ├── matrix_tiled.c      # Cache-aware tiled implementation
│   ├── matrix_vector.c     # Vector instruction implementation
│   └── utils.c             # Utility functions (timing, etc.)
├── include/
│   ├── matrix.h            # Matrix operation declarations
│   └── utils.h             # Utility function declarations
├── Makefile                # Build configuration
└── README.md               # This file
```

## Optimization Techniques Used

1. **Loop Tiling/Blocking**: Improves spatial and temporal locality
2. **Loop Unrolling**: Reduces loop overhead
3. **Data Prefetching**: Hints for cache optimization
4. **Vector Instructions**: SIMD operations for parallel computation
5. **Compiler Optimizations**: Aggressive optimization flags

## Results

Performance results will vary based on:
- Matrix size
- Cache hierarchy
- CPU frequency
- Memory bandwidth
- Vector instruction availability

Expected improvements:
- Cache-aware: 2-5x speedup over naive
- Vector instructions: Additional 2-4x speedup (architecture dependent)
