@echo off
REM Build script for RISC-V Matrix Multiplication Performance Test (Windows)
REM This script provides easy build commands for different configurations

setlocal enabledelayedexpansion

set PROJECT_NAME=matrix_mult
set BUILD_DIR=build

echo === %PROJECT_NAME% Build Script (Windows) ===
echo.

REM Check if make is available
where make >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Make utility not found. Please install make or use MinGW/MSYS2.
    echo You can install make through:
    echo   - MinGW/MSYS2: pacman -S make
    echo   - Visual Studio: Use Developer Command Prompt
    echo   - Chocolatey: choco install make
    pause
    exit /b 1
)

REM Check if gcc is available
where gcc >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: GCC compiler not found. Please install GCC.
    echo You can install GCC through:
    echo   - MinGW/MSYS2: pacman -S gcc
    echo   - TDM-GCC: https://jmeubank.github.io/tdm-gcc/
    echo   - Visual Studio: Use MSVC instead
    pause
    exit /b 1
)

REM Parse command line arguments
set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=release

echo Checking system requirements...
echo System requirements satisfied.
echo.

if /i "%BUILD_TYPE%"=="help" goto :show_help
if /i "%BUILD_TYPE%"=="-h" goto :show_help
if /i "%BUILD_TYPE%"=="--help" goto :show_help
if /i "%BUILD_TYPE%"=="clean" goto :clean_build
if /i "%BUILD_TYPE%"=="debug" goto :build_debug
if /i "%BUILD_TYPE%"=="release" goto :build_release
if /i "%BUILD_TYPE%"=="vector" goto :build_vector
if /i "%BUILD_TYPE%"=="test" goto :run_test
if /i "%BUILD_TYPE%"=="benchmark" goto :run_benchmark
if /i "%BUILD_TYPE%"=="all" goto :build_all

echo ERROR: Unknown option: %BUILD_TYPE%
echo.
goto :show_help

:show_help
echo Build script for %PROJECT_NAME%
echo.
echo Usage: %0 [option]
echo.
echo Options:
echo   help          Show this help message
echo   clean         Clean all build files
echo   debug         Build debug version
echo   release       Build optimized release version (default)
echo   vector        Build with vector instructions
echo   test          Build and run basic test
echo   benchmark     Build and run comprehensive benchmark
echo   all           Build all variants
echo.
goto :end

:clean_build
echo [STEP] Cleaning build files...
make clean
if %errorlevel% equ 0 (
    echo [INFO] Clean completed successfully
) else (
    echo [ERROR] Clean failed
    exit /b 1
)
goto :end

:build_release
echo [STEP] Building optimized release version...
make all
if %errorlevel% equ 0 (
    echo [INFO] Release build completed successfully
) else (
    echo [ERROR] Release build failed
    exit /b 1
)
goto :end

:build_debug
echo [STEP] Building debug version...
make debug
if %errorlevel% equ 0 (
    echo [INFO] Debug build completed successfully
) else (
    echo [ERROR] Debug build failed
    exit /b 1
)
goto :end

:build_vector
echo [STEP] Building with vector instructions...
make vector
if %errorlevel% equ 0 (
    echo [INFO] Vector build completed successfully
) else (
    echo [ERROR] Vector build failed
    exit /b 1
)
goto :end

:run_test
echo [STEP] Building and running basic test...
make test
if %errorlevel% equ 0 (
    echo [INFO] Test completed successfully
) else (
    echo [ERROR] Test failed
    exit /b 1
)
goto :end

:run_benchmark
echo [STEP] Building and running comprehensive benchmark...
make benchmark
if %errorlevel% equ 0 (
    echo [INFO] Benchmark completed successfully
) else (
    echo [ERROR] Benchmark failed
    exit /b 1
)
goto :end

:build_all
echo [STEP] Building all variants...

echo [INFO] Building release version...
make clean
make all
if %errorlevel% equ 0 (
    if exist %PROJECT_NAME%.exe (
        move %PROJECT_NAME%.exe %PROJECT_NAME%_release.exe
    )
) else (
    echo [ERROR] Release build failed
    exit /b 1
)

echo [INFO] Building debug version...
make clean
make debug
if %errorlevel% equ 0 (
    if exist %PROJECT_NAME%.exe (
        move %PROJECT_NAME%.exe %PROJECT_NAME%_debug.exe
    )
) else (
    echo [ERROR] Debug build failed
    exit /b 1
)

echo [INFO] Building vector version...
make clean
make vector
if %errorlevel% equ 0 (
    if exist %PROJECT_NAME%.exe (
        move %PROJECT_NAME%.exe %PROJECT_NAME%_vector.exe
    )
) else (
    echo [ERROR] Vector build failed
    exit /b 1
)

echo [INFO] All variants built successfully:
echo   - %PROJECT_NAME%_release.exe (optimized)
echo   - %PROJECT_NAME%_debug.exe (with debug info)
echo   - %PROJECT_NAME%_vector.exe (with vector instructions)
goto :end

:end
echo.
echo [INFO] Build script completed!
pause
