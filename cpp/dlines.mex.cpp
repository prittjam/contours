#include <iostream>
#include "curvature/curvature.hpp"

#include "mexplus/arguments.h"
#include "mexplus/dispatch.h"
#include "mexplusplus/eigen/eigen.hpp"

using namespace mexplus;
 
MEX_DEFINE(calc_orientation)(int nlhs, mxArray* plhs[],
                             int nrhs, const mxArray* prhs[]) 
{
  typedef double Scalar;

  typedef Eigen::Matrix<Scalar,2,1> Vector2;
  
  std::vector<Vector2> contour;
  std::vector<double> orientation_list;

  InputArguments input(nrhs, prhs,1,1,"stride");
  OutputArguments output(nlhs, plhs, 1);

  const int stride = input.get<int>("stride",5);

  try {
    mexplus::MxArray::to<std::vector<Vector2> >(prhs[0],&contour);
    orientation_list = calc_orientation(contour,stride);
    
    plhs[0] = mexplus::MxArray::from(orientation_list);
  }
  catch(const std::exception& t) {
    std::cout << "Unable to parse parameters" << std::endl;
  }
}

MEX_DEFINE(calc_curvature)(int nlhs, mxArray* plhs[],
                           int nrhs, const mxArray* prhs[]) 
{
  typedef double Scalar;

  typedef Eigen::Matrix<Scalar,2,1> Vector2;
  
  std::vector<Vector2> contour;
  std::vector<double> curvature_list;

  InputArguments input(nrhs, prhs,1,1,"stride");
  OutputArguments output(nlhs, plhs, 1);

  const int stride = input.get<int>("stride",5);

  try {
    mexplus::MxArray::to<std::vector<Vector2> >(prhs[0],&contour);
    curvature_list = calc_curvature(contour,stride);
    plhs[0] = mexplus::MxArray::from(curvature_list);
  }
  catch(const std::exception& t) {
    std::cout << "Unable to parse parameters" << std::endl;
  }
}

MEX_DISPATCH
