# Git repository setup instructions for RISC-V Matrix Multiplication Project

## Initial Repository Setup

### 1. Initialize Git Repository
```bash
git init
git add .
git commit -m "Initial commit: RISC-V matrix multiplication performance test"
```

### 2. Create .gitignore
```bash
# Build artifacts
*.o
*.exe
matrix_mult
matrix_mult_*
build/
*.a
*.so

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Test results
performance_report.txt
performance_data.csv
*.log

# Temporary files
*.tmp
*.temp
```

### 3. Setup Remote Repository (GitHub)

#### Create repository on GitHub
1. Go to GitHub and create a new repository
2. Name it "risc-v-matrix-optimization" or similar
3. Don't initialize with README (we already have one)

#### Connect local repository to GitHub
```bash
git remote add origin https://github.com/YOUR_USERNAME/risc-v-matrix-optimization.git
git branch -M main
git push -u origin main
```

### 4. Create GitHub Actions for CI/CD (optional)

Create `.github/workflows/ci.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        build-type: [release, debug, vector]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y build-essential
    
    - name: Build project
      run: make ${{ matrix.build-type }}
    
    - name: Run tests
      run: ./matrix_mult 128
    
    - name: Run verification
      run: ./matrix_mult -v 64

  cross-compile-riscv:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install RISC-V toolchain
      run: |
        sudo apt-get update
        sudo apt-get install -y gcc-riscv64-linux-gnu
    
    - name: Cross-compile for RISC-V
      run: make riscv
    
    - name: Upload RISC-V binary
      uses: actions/upload-artifact@v3
      with:
        name: matrix-mult-riscv
        path: matrix_mult
```

## Repository Structure

```
risc-v-matrix-optimization/
├── .github/
│   └── workflows/
│       └── ci.yml
├── .gitignore
├── README.md
├── RESULTS.md
├── Makefile
├── build.sh
├── build.bat
├── test.sh
├── include/
│   ├── config.h
│   ├── matrix.h
│   └── utils.h
└── src/
    ├── main.c
    ├── matrix_naive.c
    ├── matrix_tiled.c
    ├── matrix_vector.c
    └── utils.c
```

## Recommended Branches

- `main`: Stable, production-ready code
- `develop`: Development branch for new features
- `feature/*`: Feature development branches
- `optimization/*`: Performance optimization branches
- `riscv-*`: RISC-V specific implementations

## Tags and Releases

Create semantic version tags:
```bash
git tag -a v1.0.0 -m "Initial release: Basic matrix multiplication with naive and tiled implementations"
git push origin v1.0.0
```

## Contributing Guidelines

### Commit Message Format
```
type(scope): brief description

Longer description if needed

- Change 1
- Change 2
```

Types: `feat`, `fix`, `perf`, `refactor`, `test`, `docs`, `style`, `chore`

### Example Commits
```bash
git commit -m "feat(matrix): add vector instruction implementation"
git commit -m "perf(tiled): optimize tile size calculation for RISC-V"
git commit -m "test: add comprehensive performance benchmarks"
git commit -m "docs: update README with build instructions"
```

## GitHub Repository Description

**Title**: RISC-V Matrix Multiplication Performance Optimization

**Description**: 
High-performance matrix multiplication implementations for RISC-V architecture featuring naive, cache-aware (tiled), and vector instruction variants. Includes comprehensive benchmarking and performance analysis tools.

**Topics**: 
`risc-v`, `matrix-multiplication`, `performance-optimization`, `cache-optimization`, `vector-instructions`, `hpc`, `linear-algebra`, `c`, `benchmarking`

## README Badges (for GitHub)

Add these to the top of your README.md:

```markdown
[![Build Status](https://github.com/YOUR_USERNAME/risc-v-matrix-optimization/workflows/CI%2FCD%20Pipeline/badge.svg)](https://github.com/YOUR_USERNAME/risc-v-matrix-optimization/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-RISC--V-blue.svg)](https://riscv.org/)
[![Language](https://img.shields.io/badge/language-C-blue.svg)](https://en.wikipedia.org/wiki/C_(programming_language))
```
