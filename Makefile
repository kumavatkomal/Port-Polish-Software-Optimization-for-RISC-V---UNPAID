# Makefile for RISC-V Matrix Multiplication Performance Test

# Project name
PROJECT = matrix_mult

# Directories
SRC_DIR = src
INC_DIR = include
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj

# Source files
SOURCES = $(wildcard $(SRC_DIR)/*.c)
OBJECTS = $(SOURCES:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

# Compiler configuration
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -I$(INC_DIR)
LDFLAGS = -lm -lrt

# Optimization flags
OPT_FLAGS = -O3 -march=native -mtune=native -funroll-loops -ffast-math

# Debug flags
DEBUG_FLAGS = -g -O0 -DDEBUG

# Vector instruction flags
VECTOR_FLAGS = -DUSE_VECTOR

# Build targets
.PHONY: all clean debug vector help install uninstall

# Default target
all: CFLAGS += $(OPT_FLAGS)
all: $(PROJECT)

# Debug build
debug: CFLAGS += $(DEBUG_FLAGS)
debug: $(PROJECT)

# Vector instruction build
vector: CFLAGS += $(OPT_FLAGS) $(VECTOR_FLAGS)
vector: $(PROJECT)

# Debug build with vector instructions
debug-vector: CFLAGS += $(DEBUG_FLAGS) $(VECTOR_FLAGS)
debug-vector: $(PROJECT)

# Main executable
$(PROJECT): $(BUILD_DIR) $(OBJECTS)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS)

# Object files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(OBJ_DIR)

# Clean build files
clean:
	@echo "Cleaning build files..."
	@rm -rf $(BUILD_DIR)
	@rm -f $(PROJECT)
	@rm -f *.o
	@echo "Clean complete."

# Install (copy to /usr/local/bin)
install: $(PROJECT)
	@echo "Installing $(PROJECT) to /usr/local/bin..."
	sudo cp $(PROJECT) /usr/local/bin/
	@echo "Installation complete."

# Uninstall
uninstall:
	@echo "Removing $(PROJECT) from /usr/local/bin..."
	sudo rm -f /usr/local/bin/$(PROJECT)
	@echo "Uninstall complete."

# Performance test targets
test: $(PROJECT)
	@echo "Running performance tests..."
	./$(PROJECT) 256
	@echo "Small test complete."

test-large: $(PROJECT)
	@echo "Running large performance test..."
	./$(PROJECT) 1024
	@echo "Large test complete."

test-verify: $(PROJECT)
	@echo "Running verification test..."
	./$(PROJECT) -v 128
	@echo "Verification test complete."

test-all: test test-large test-verify
	@echo "All tests complete."

# Benchmark suite
benchmark: $(PROJECT)
	@echo "Running comprehensive benchmark suite..."
	@echo "=== Small matrices ==="
	./$(PROJECT) 64
	./$(PROJECT) 128
	./$(PROJECT) 256
	@echo "=== Medium matrices ==="
	./$(PROJECT) 512
	./$(PROJECT) 768
	@echo "=== Large matrices ==="
	./$(PROJECT) 1024
	./$(PROJECT) 1536
	@echo "Benchmark suite complete."

# RISC-V cross-compilation (requires RISC-V toolchain)
riscv: CC = riscv64-unknown-linux-gnu-gcc
riscv: CFLAGS += $(OPT_FLAGS) -static
riscv: $(PROJECT)

riscv-vector: CC = riscv64-unknown-linux-gnu-gcc
riscv-vector: CFLAGS += $(OPT_FLAGS) $(VECTOR_FLAGS) -static -march=rv64gcv
riscv-vector: $(PROJECT)

# Analysis targets
analyze: $(PROJECT)
	@echo "Analyzing performance characteristics..."
	@echo "Testing different tile sizes..."
	./$(PROJECT) -t 16 512
	./$(PROJECT) -t 32 512
	./$(PROJECT) -t 64 512
	./$(PROJECT) -t 128 512
	@echo "Analysis complete."

# Profile build (requires gprof)
profile: CFLAGS += $(OPT_FLAGS) -pg
profile: LDFLAGS += -pg
profile: $(PROJECT)

# Memory check (requires valgrind)
memcheck: debug
	valgrind --tool=memcheck --leak-check=full ./$(PROJECT) 64

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Build optimized version (default)"
	@echo "  debug        - Build debug version"
	@echo "  vector       - Build with vector instructions"
	@echo "  debug-vector - Build debug version with vector instructions"
	@echo "  clean        - Clean build files"
	@echo "  test         - Run basic performance test"
	@echo "  test-large   - Run large matrix test"
	@echo "  test-verify  - Run verification test"
	@echo "  test-all     - Run all tests"
	@echo "  benchmark    - Run comprehensive benchmark suite"
	@echo "  riscv        - Cross-compile for RISC-V"
	@echo "  riscv-vector - Cross-compile for RISC-V with vector extensions"
	@echo "  analyze      - Analyze performance with different parameters"
	@echo "  profile      - Build with profiling support"
	@echo "  memcheck     - Run memory check with valgrind"
	@echo "  install      - Install to /usr/local/bin"
	@echo "  uninstall    - Remove from /usr/local/bin"
	@echo "  help         - Show this help message"

# Dependencies
$(OBJ_DIR)/main.o: $(INC_DIR)/matrix.h $(INC_DIR)/utils.h
$(OBJ_DIR)/matrix_naive.o: $(INC_DIR)/matrix.h $(INC_DIR)/utils.h
$(OBJ_DIR)/matrix_tiled.o: $(INC_DIR)/matrix.h $(INC_DIR)/utils.h
$(OBJ_DIR)/matrix_vector.o: $(INC_DIR)/matrix.h $(INC_DIR)/utils.h
$(OBJ_DIR)/utils.o: $(INC_DIR)/utils.h
