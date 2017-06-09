cmake_minimum_required(VERSION 3.6)
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

find_package(Matlab REQUIRED)
find_package(Eigen3 REQUIRED NO_MODULE)

include_directories(EIGEN3_INCLUDE_DIR .)

matlab_add_mex(NAME dlines SRC dlines.mex.cpp OUTPUT_NAME dlines)
target_include_directories(dlines PRIVATE ~/src/mexplus/include ~/src/mexplusplus/cpp)
target_compile_options(dlines PRIVATE "-std=c++11")

install(TARGETS dlines LIBRARY DESTINATION mex)
