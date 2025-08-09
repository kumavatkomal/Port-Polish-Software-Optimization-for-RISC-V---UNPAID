#!/bin/bash

# Comprehensive test script for RISC-V Matrix Multiplication Performance Test
# This script runs various tests and generates performance reports

set -e

PROJECT_NAME="matrix_mult"
REPORT_FILE="performance_report.txt"
CSV_FILE="performance_data.csv"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Initialize report files
init_reports() {
    echo "RISC-V Matrix Multiplication Performance Report" > $REPORT_FILE
    echo "Generated on: $(date)" >> $REPORT_FILE
    echo "System: $(uname -a)" >> $REPORT_FILE
    echo "======================================================" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    
    echo "Matrix Size,Method,Time (ms),GFLOPS" > $CSV_FILE
}

# Function to run a single test and capture output
run_test() {
    local size=$1
    local args=$2
    local description=$3
    
    print_status "Running test: $description (size: $size)"
    
    if [ ! -f "./$PROJECT_NAME" ]; then
        print_error "Executable not found. Please build the project first."
        return 1
    fi
    
    echo "Test: $description" >> $REPORT_FILE
    echo "Matrix Size: $size" >> $REPORT_FILE
    echo "Arguments: $args" >> $REPORT_FILE
    echo "Output:" >> $REPORT_FILE
    
    ./$PROJECT_NAME $args $size 2>&1 | tee -a $REPORT_FILE
    
    echo "" >> $REPORT_FILE
    echo "------------------------------------------------------" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
}

# Function to run correctness tests
run_correctness_tests() {
    print_header "Running Correctness Tests"
    
    local test_sizes=(64 128 256)
    
    for size in "${test_sizes[@]}"; do
        run_test $size "-v" "Correctness verification (size: $size)"
    done
}

# Function to run performance tests
run_performance_tests() {
    print_header "Running Performance Tests"
    
    local test_sizes=(64 128 256 512 1024)
    
    for size in "${test_sizes[@]}"; do
        run_test $size "" "Performance test (size: $size)"
    done
}

# Function to run scaling tests
run_scaling_tests() {
    print_header "Running Scaling Tests"
    
    local test_sizes=(32 64 96 128 160 192 224 256 320 384 448 512)
    
    for size in "${test_sizes[@]}"; do
        run_test $size "" "Scaling test (size: $size)"
    done
}

# Function to test different tile sizes
run_tile_size_tests() {
    print_header "Running Tile Size Optimization Tests"
    
    local tile_sizes=(16 32 48 64 96 128)
    local matrix_size=512
    
    for tile in "${tile_sizes[@]}"; do
        run_test $matrix_size "-t $tile" "Tile size test (tile: $tile, matrix: $matrix_size)"
    done
}

# Function to run memory stress tests
run_memory_tests() {
    print_header "Running Memory Stress Tests"
    
    # Test with large matrices (if system has enough memory)
    local large_sizes=(1024 1536 2048)
    
    for size in "${large_sizes[@]}"; do
        # Check available memory before running large tests
        local required_memory=$((size * size * 8 * 3 / 1024 / 1024)) # MB
        local available_memory=$(free -m | awk 'NR==2{print $7}')
        
        if [ $available_memory -gt $((required_memory * 2)) ]; then
            run_test $size "" "Memory stress test (size: $size)"
        else
            print_warning "Skipping size $size: insufficient memory (need ${required_memory}MB, have ${available_memory}MB)"
        fi
    done
}

# Function to run vector instruction tests (if available)
run_vector_tests() {
    print_header "Testing Vector Instructions"
    
    # Build with vector instructions
    print_status "Building with vector instructions..."
    make clean && make vector
    
    if [ $? -eq 0 ]; then
        local test_sizes=(128 256 512)
        
        for size in "${test_sizes[@]}"; do
            run_test $size "" "Vector instruction test (size: $size)"
        done
    else
        print_warning "Failed to build with vector instructions"
    fi
    
    # Restore regular build
    print_status "Restoring regular build..."
    make clean && make all
}

# Function to generate performance summary
generate_summary() {
    print_header "Generating Performance Summary"
    
    echo "" >> $REPORT_FILE
    echo "PERFORMANCE SUMMARY" >> $REPORT_FILE
    echo "===================" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    
    # Extract performance data from report
    grep -E "(Naive|Tiled|Vector)" $REPORT_FILE | grep -E "[0-9]+\.[0-9]+ GFLOPS" >> $REPORT_FILE || true
    
    print_status "Performance report saved to: $REPORT_FILE"
    print_status "CSV data saved to: $CSV_FILE"
}

# Function to check system information
check_system() {
    print_header "System Information"
    
    echo "System Information:" >> $REPORT_FILE
    echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)" >> $REPORT_FILE || echo "CPU: Unknown" >> $REPORT_FILE
    echo "Memory: $(free -h | awk 'NR==2{print $2}')" >> $REPORT_FILE
    echo "OS: $(uname -o)" >> $REPORT_FILE
    echo "Kernel: $(uname -r)" >> $REPORT_FILE
    echo "Architecture: $(uname -m)" >> $REPORT_FILE
    
    if command -v gcc >/dev/null 2>&1; then
        echo "GCC Version: $(gcc --version | head -n1)" >> $REPORT_FILE
    fi
    
    echo "" >> $REPORT_FILE
}

# Function to run all tests
run_all_tests() {
    print_header "RISC-V Matrix Multiplication Comprehensive Test Suite"
    
    # Initialize
    init_reports
    check_system
    
    # Build the project
    print_status "Building project..."
    make clean && make all
    
    if [ $? -ne 0 ]; then
        print_error "Failed to build project"
        exit 1
    fi
    
    # Run test suites
    run_correctness_tests
    run_performance_tests
    run_scaling_tests
    run_tile_size_tests
    run_memory_tests
    
    # Vector tests (optional, might not be available on all systems)
    if [[ "$*" == *"--include-vector"* ]]; then
        run_vector_tests
    fi
    
    # Generate summary
    generate_summary
    
    print_status "All tests completed successfully!"
    print_status "Check $REPORT_FILE for detailed results"
}

# Function to show help
show_help() {
    echo "Comprehensive test script for $PROJECT_NAME"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --help              Show this help message"
    echo "  --correctness       Run only correctness tests"
    echo "  --performance       Run only performance tests"
    echo "  --scaling           Run only scaling tests"
    echo "  --tile-size         Run only tile size tests"
    echo "  --memory            Run only memory stress tests"
    echo "  --vector            Run only vector instruction tests"
    echo "  --include-vector    Include vector tests in full suite"
    echo "  --all               Run all test suites (default)"
    echo ""
}

# Main script logic
main() {
    case "${1:-all}" in
        "--help"|"-h")
            show_help
            ;;
        "--correctness")
            init_reports && check_system && make clean && make all && run_correctness_tests && generate_summary
            ;;
        "--performance")
            init_reports && check_system && make clean && make all && run_performance_tests && generate_summary
            ;;
        "--scaling")
            init_reports && check_system && make clean && make all && run_scaling_tests && generate_summary
            ;;
        "--tile-size")
            init_reports && check_system && make clean && make all && run_tile_size_tests && generate_summary
            ;;
        "--memory")
            init_reports && check_system && make clean && make all && run_memory_tests && generate_summary
            ;;
        "--vector")
            init_reports && check_system && run_vector_tests && generate_summary
            ;;
        "--all"|"")
            run_all_tests "$@"
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
