#!/bin/bash

# Build script for RISC-V Matrix Multiplication Performance Test
# This script provides easy build commands for different configurations

set -e  # Exit on any error

PROJECT_NAME="matrix_mult"
BUILD_DIR="build"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to display help
show_help() {
    echo "Build script for $PROJECT_NAME"
    echo ""
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  help          Show this help message"
    echo "  clean         Clean all build files"
    echo "  debug         Build debug version"
    echo "  release       Build optimized release version (default)"
    echo "  vector        Build with vector instructions"
    echo "  riscv         Cross-compile for RISC-V"
    echo "  test          Build and run basic test"
    echo "  benchmark     Build and run comprehensive benchmark"
    echo "  all           Build all variants"
    echo ""
}

# Function to clean build
clean_build() {
    print_step "Cleaning build files..."
    make clean
    print_status "Clean completed successfully"
}

# Function to build release version
build_release() {
    print_step "Building optimized release version..."
    make all
    print_status "Release build completed successfully"
}

# Function to build debug version
build_debug() {
    print_step "Building debug version..."
    make debug
    print_status "Debug build completed successfully"
}

# Function to build vector version
build_vector() {
    print_step "Building with vector instructions..."
    make vector
    print_status "Vector build completed successfully"
}

# Function to cross-compile for RISC-V
build_riscv() {
    print_step "Cross-compiling for RISC-V..."
    
    if ! command_exists "riscv64-unknown-linux-gnu-gcc"; then
        print_warning "RISC-V toolchain not found. Installing prerequisites..."
        echo "Please install RISC-V GNU toolchain:"
        echo "  Ubuntu/Debian: sudo apt-get install gcc-riscv64-linux-gnu"
        echo "  Or build from source: https://github.com/riscv/riscv-gnu-toolchain"
        return 1
    fi
    
    make riscv
    print_status "RISC-V build completed successfully"
}

# Function to run tests
run_test() {
    print_step "Building and running basic test..."
    make test
    print_status "Test completed successfully"
}

# Function to run benchmark
run_benchmark() {
    print_step "Building and running comprehensive benchmark..."
    make benchmark
    print_status "Benchmark completed successfully"
}

# Function to build all variants
build_all() {
    print_step "Building all variants..."
    
    print_status "Building release version..."
    make clean && make all
    mv $PROJECT_NAME ${PROJECT_NAME}_release
    
    print_status "Building debug version..."
    make clean && make debug
    mv $PROJECT_NAME ${PROJECT_NAME}_debug
    
    print_status "Building vector version..."
    make clean && make vector
    mv $PROJECT_NAME ${PROJECT_NAME}_vector
    
    print_status "All variants built successfully:"
    echo "  - ${PROJECT_NAME}_release (optimized)"
    echo "  - ${PROJECT_NAME}_debug (with debug info)"
    echo "  - ${PROJECT_NAME}_vector (with vector instructions)"
}

# Function to check system requirements
check_requirements() {
    print_step "Checking system requirements..."
    
    if ! command_exists "gcc"; then
        print_error "GCC compiler not found. Please install GCC."
        exit 1
    fi
    
    if ! command_exists "make"; then
        print_error "Make utility not found. Please install make."
        exit 1
    fi
    
    print_status "System requirements satisfied"
}

# Main script logic
main() {
    echo "=== $PROJECT_NAME Build Script ==="
    echo ""
    
    # Check requirements
    check_requirements
    
    # Parse command line arguments
    case "${1:-release}" in
        "help"|"-h"|"--help")
            show_help
            ;;
        "clean")
            clean_build
            ;;
        "debug")
            build_debug
            ;;
        "release")
            build_release
            ;;
        "vector")
            build_vector
            ;;
        "riscv")
            build_riscv
            ;;
        "test")
            build_release && run_test
            ;;
        "benchmark")
            build_release && run_benchmark
            ;;
        "all")
            build_all
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
    
    echo ""
    print_status "Build script completed successfully!"
}

# Run main function
main "$@"
