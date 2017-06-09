cmake_minimum_required(VERSION 3.6)
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

find_package(Matlab REQUIRED)
find_package(Eigen3 REQUIRED NO_MODULE)

matlab_add_mex(NAME dlines SRC dlines.mex.cpp OUTPUT_NAME dlines)

include_directories(EIGEN3_INCLUDE_DIR .)
target_include_directories(dlines PRIVATE ${PROJECT_SOURCE_DIR}/external/mexplus/include 
                                  ${PROJECT_SOURCE_DIR}/external/mexplusplus/cpp)

target_compile_options(dlines PRIVATE "-std=c++11")

install(TARGETS dlines LIBRARY DESTINATION mex)
