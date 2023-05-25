@echo off
REM Example command to build the mobile target.
REM
REM This script shows how one can build a libtorch library optimized for mobile
REM devices using host toolchain.

setlocal enabledelayedexpansion

set "BUILD_PYTORCH_MOBILE_WITH_HOST_TOOLCHAIN=1"
set "CAFFE2_ROOT=%~dp0thirdparty\pytorch"

echo "Batch: %ComSpec%"

echo "Caffe2 path: %CAFFE2_ROOT%"

set "CMAKE_ARGS="
set "CMAKE_ARGS=-DCMAKE_PREFIX_PATH=%~dp0thirdparty\pytorch\%PY_SITE_PKG%"

for /f "usebackq tokens=*" %%i in (`python -c "import sys; print(sys.executable)"`) do (
  set "PYTHON_EXECUTABLE=%%~i"
)
set "CMAKE_ARGS=%CMAKE_ARGS% -DPYTHON_EXECUTABLE=%PYTHON_EXECUTABLE%"

set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_CUSTOM_PROTOBUF=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_SHARED_LIBS=OFF"

REM custom build with selected ops
if defined SELECTED_OP_LIST (
  set "SELECTED_OP_LIST=%~dp0%SELECTED_OP_LIST%"
  echo "Choose SELECTED_OP_LIST file: %SELECTED_OP_LIST%"
  if not exist "%SELECTED_OP_LIST%" (
    echo "Error: SELECTED_OP_LIST file %SELECTED_OP_LIST% not found."
    exit /b 1
  )
  set "CMAKE_ARGS=%CMAKE_ARGS% -DSELECTED_OP_LIST=%SELECTED_OP_LIST%"
)

REM Don't build artifacts we don't need
set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_PYTHON=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_TEST=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_BINARY=OFF"

REM If there exists env variable and it equals to 1, build lite interpreter.
REM Default behavior is to build full jit interpreter.
REM cmd: BUILD_LITE_INTERPRETER=1 .\scripts\build_mobile.bat
if "%BUILD_LITE_INTERPRETER%"=="1" (
  set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_LITE_INTERPRETER=ON"
) else (
  set "CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_LITE_INTERPRETER=OFF"
)
REM if "%TRACING_BASED%"=="1" (
  set "CMAKE_ARGS=%CMAKE_ARGS% -DTRACING_BASED=ON"
REM ) else (
REM   set "CMAKE_ARGS=%CMAKE_ARGS% -DTRACING_BASED=OFF"
REM )

REM Lightweight dispatch bypasses the PyTorch Dispatcher.
if "%USE_LIGHTWEIGHT_DISPATCH%"=="1" (
  set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_LIGHTWEIGHT_DISPATCH=ON"
  set "CMAKE_ARGS=%CMAKE_ARGS% -DSTATIC_DISPATCH_BACKEND=CPU"
) else (
  set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_LIGHTWEIGHT_DISPATCH=OFF"
)

REM Enable Vulkan
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_VULKAN=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_OPENCV=ON"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_BLAS=ON"
REM set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_KINETO=OFF"

REM Disable unused dependencies
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_ROCM=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_CUDA=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_ITT=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_GFLAGS=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_GLOO=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_LMDB=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_LEVELDB=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_MPI=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_OPENMP=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_MKLDNN=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_NNPACK=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_NUMPY=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_TENSORPIPE=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_OBSERVERS=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DMSVC_Z7_OVERRIDE=OFF"

set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_QNNPACK=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_PYTORCH_QNNPACK=OFF"
set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_FBGEMM=OFF"



set "CMAKE_ARGS=%CMAKE_ARGS% -DUSE_DISTRIBUTED=OFF"


REM Only toggle if VERBOSE=1
if "%VERBOSE%"=="1" (
  set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_VERBOSE_MAKEFILE=1"
)

REM Use-specified CMake arguments go last to allow overriding defaults
set "CMAKE_ARGS=%CMAKE_ARGS% %*"

REM Now, actually build the Android target.
set "BUILD_ROOT=%CAFFE2_ROOT%\runtime%"
set "INSTALL_PREFIX=%BUILD_ROOT%\install%"
mkdir "%BUILD_ROOT%"
cd "%BUILD_ROOT%"

echo %BUILD_ROOT%

echo "Cmake Args: %CMAKE_ARGS%"
cmake "%CAFFE2_ROOT%" ^
    -DCMAKE_INSTALL_PREFIX=%INSTALL_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    %CMAKE_ARGS%

echo "Will install headers and libs to %INSTALL_PREFIX% for further project usage."
cmake --build . --target install
echo "Installation completed, now you can copy the headers/libs from %INSTALL_PREFIX% to your project directory."
