@echo off
REM Simple build script for Windows without make
REM This script manually compiles the matrix multiplication project

setlocal enabledelayedexpansion

set PROJECT_NAME=matrix_mult
set SRC_DIR=src
set INC_DIR=include
set BUILD_DIR=build
set OBJ_DIR=%BUILD_DIR%\obj

echo === RISC-V Matrix Multiplication Build Script (Windows) ===
echo.

REM Create build directories
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%OBJ_DIR%" mkdir "%OBJ_DIR%"

REM Check if GCC is available
where gcc >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: GCC compiler not found. Please install GCC.
    pause
    exit /b 1
)

echo [INFO] GCC found: 
gcc --version | findstr "gcc"
echo.

REM Parse build type
set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=release

REM Set compiler flags based on build type
if /i "%BUILD_TYPE%"=="debug" (
    set CFLAGS=-Wall -Wextra -std=c99 -I%INC_DIR% -g -O0 -DDEBUG
    echo [INFO] Building debug version...
) else if /i "%BUILD_TYPE%"=="vector" (
    set CFLAGS=-Wall -Wextra -std=c99 -I%INC_DIR% -O3 -march=native -mtune=native -funroll-loops -ffast-math -DUSE_VECTOR
    echo [INFO] Building with vector instructions...
) else (
    set CFLAGS=-Wall -Wextra -std=c99 -I%INC_DIR% -O3 -march=native -mtune=native -funroll-loops -ffast-math
    echo [INFO] Building optimized release version...
)

set LDFLAGS=-lm

echo [STEP] Compiling source files...

REM Compile each source file
echo   Compiling utils.c...
gcc !CFLAGS! -c %SRC_DIR%\utils.c -o %OBJ_DIR%\utils.o
if %errorlevel% neq 0 (
    echo [ERROR] Failed to compile utils.c
    pause
    exit /b 1
)

echo   Compiling matrix_naive.c...
gcc !CFLAGS! -c %SRC_DIR%\matrix_naive.c -o %OBJ_DIR%\matrix_naive.o
if %errorlevel% neq 0 (
    echo [ERROR] Failed to compile matrix_naive.c
    pause
    exit /b 1
)

echo   Compiling matrix_tiled.c...
gcc !CFLAGS! -c %SRC_DIR%\matrix_tiled.c -o %OBJ_DIR%\matrix_tiled.o
if %errorlevel% neq 0 (
    echo [ERROR] Failed to compile matrix_tiled.c
    pause
    exit /b 1
)

echo   Compiling matrix_vector.c...
gcc !CFLAGS! -c %SRC_DIR%\matrix_vector.c -o %OBJ_DIR%\matrix_vector.o
if %errorlevel% neq 0 (
    echo [ERROR] Failed to compile matrix_vector.c
    pause
    exit /b 1
)

echo   Compiling main.c...
gcc !CFLAGS! -c %SRC_DIR%\main.c -o %OBJ_DIR%\main.o
if %errorlevel% neq 0 (
    echo [ERROR] Failed to compile main.c
    pause
    exit /b 1
)

echo [STEP] Linking executable...
gcc %OBJ_DIR%\*.o -o %PROJECT_NAME%.exe !LDFLAGS!
if %errorlevel% neq 0 (
    echo [ERROR] Failed to link executable
    pause
    exit /b 1
)

echo [SUCCESS] Build completed successfully!
echo           Executable: %PROJECT_NAME%.exe
echo           Build type: %BUILD_TYPE%
echo.

REM Run a quick test if requested
if /i "%2"=="test" (
    echo [INFO] Running quick test...
    %PROJECT_NAME%.exe 64
)

echo Build script finished.
pause
