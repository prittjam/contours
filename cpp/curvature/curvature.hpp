#ifndef __CURVATURE_HPP__
#define __CURVATURE_HPP__ 

#include <vector>
#include <algorithm>
#include <eigen3/Eigen/Dense>

template<typename _Scalar, size_t _N>
struct Rn
{
  typedef Eigen::Matrix<_Scalar,_N,1> Vector;
  typedef _Scalar Scalar;
  const static int Dimension = Vector::RowsAtCompileTime;
};

template<typename Scalar>
std::vector<double> 
calc_orientation(const std::vector<Eigen::Matrix<Scalar,2,1> >& vecContourPoints, 
                 const int step)
{

  static const Scalar piover2 = 3.14159265358/2.0;
  typedef Eigen::Matrix<Scalar,2,1> Vector2;
  std::vector< double > vecOrientation( vecContourPoints.size() );

  if (vecContourPoints.size() < step)
    return vecOrientation;

  auto frontToBack = vecContourPoints.front() - vecContourPoints.back();
  //    std::cout << CONTENT_OF(frontToBack) << std::endl;
  bool isClosed = ((int)std::max(std::abs(frontToBack[0]), 
                                 std::abs(frontToBack[1]))) <= 1;

  Vector2 pplus, pminus;
  Vector2 f1stDerivative;
  for (int i = 0; i < vecContourPoints.size(); i++ )
    {
      const Vector2& pos = vecContourPoints[i];
      int maxStep = step;
      if (!isClosed) {
        maxStep = std::min(std::min(step, i), (int)vecContourPoints.size()-1-i);
        if (maxStep == 0) {
          vecOrientation[i] = std::numeric_limits<double>::quiet_NaN(); 
          continue;
        }
      }

      int iminus = i-maxStep;
      int iplus = i+maxStep;
      pminus = vecContourPoints[iminus < 0 ? iminus + vecContourPoints.size() : iminus];
      pplus = vecContourPoints[iplus > vecContourPoints.size() ? iplus - vecContourPoints.size() : iplus];

      f1stDerivative[0] =   (pplus[0]-pminus[0]) / (iplus-iminus);
      f1stDerivative[1] =   (pplus[1]-pminus[1]) / (iplus-iminus);
      
      if (std::abs(f1stDerivative[0]) > 0) {
        vecOrientation[i] = atan(f1stDerivative[1]/f1stDerivative[0])+piover2;
      }
      else {
        vecOrientation[i] = 0;
      }
    }
  return vecOrientation;
}


template<typename Scalar>
std::vector<double> 
calc_curvature(const std::vector<Eigen::Matrix<Scalar,2,1> >& vecContourPoints, 
               const int step)
{
  typedef Eigen::Matrix<Scalar,2,1> Vector2;
  std::vector< double > vecCurvature( vecContourPoints.size() );

  if (vecContourPoints.size() < step)
    return vecCurvature;

  auto frontToBack = vecContourPoints.front() - vecContourPoints.back();
  //    std::cout << CONTENT_OF(frontToBack) << std::endl;
  bool isClosed = ((int)std::max(std::abs(frontToBack[0]), 
                                 std::abs(frontToBack[1]))) <= 1;

  Vector2 pplus, pminus;
  Vector2 f1stDerivative, f2ndDerivative;
  for (int i = 0; i < vecContourPoints.size(); i++ )
    {
      const Vector2& pos = vecContourPoints[i];

      int maxStep = step;
      if (!isClosed) {
        maxStep = std::min(std::min(step, i), (int)vecContourPoints.size()-1-i);
        if (maxStep == 0)  {
          vecCurvature[i] = std::numeric_limits<double>::quiet_NaN(); 
          continue;
        }
      }

      int iminus = i-maxStep;
      int iplus = i+maxStep;
      pminus = vecContourPoints[iminus < 0 ? iminus + vecContourPoints.size() : iminus];
      pplus = vecContourPoints[iplus > vecContourPoints.size() ? iplus - vecContourPoints.size() : iplus];


      f1stDerivative[0] =   (pplus[0]-pminus[0]) / (iplus-iminus);
      f1stDerivative[1] =   (pplus[1]-pminus[1]) / (iplus-iminus);
      f2ndDerivative[0] = (pplus[0] - 2*pos[0] + pminus[0]) / ((iplus-iminus)/2*(iplus-iminus)/2);
      f2ndDerivative[1] = (pplus[1] - 2*pos[1] + pminus[1]) / ((iplus-iminus)/2*(iplus-iminus)/2);

      double curvature2D;
      double divisor = f1stDerivative[0]*f1stDerivative[0] + f1stDerivative[1]*f1stDerivative[1];
      if ( std::abs(divisor) > 10e-8 ) {
          curvature2D =  std::abs(f2ndDerivative[1]*f1stDerivative[0] - f2ndDerivative[0]*f1stDerivative[1]) /
            pow(divisor, 3.0/2.0 )  ;
      }
      else {
        curvature2D = std::numeric_limits<double>::quiet_NaN();
      }

      vecCurvature[i] = curvature2D;
    }
  return vecCurvature;
}

#endif


//rvature(std::vector<> const& vecContourPoints, int step)
//{
//    std::vector< double > vecCurvature( vecContourPoints.size() );
//
//    if (vecContourPoints.size() < step)
//    return vecCurvature;
//
//    auto frontToBack = vecContourPoints.front() - vecContourPoints.back();
//    std::cout << CONTENT_OF(frontToBack) << std::endl;
//    bool isClosed = ((int)std::max(std::abs(frontToBack[0]), std::abs(frontToBack[1]))) <= 1;
//
//    cv::Point2fg pplus, pminus;
//    cv::Point2f f1stDerivative, f2ndDerivative;
//    for (int i = 0; i < vecContourPoints.size(); i++ )
//        {
//            const cv::Point2f& pos = vecContourPoints[i];
//
//            int maxStep = step;
//            if (!isClosed)
//            {
//                maxStep = std::min(std::min(step, i), (int)vecContourPoints.size()-1-i);
//                if (maxStep == 0)
//                {
//                    vecCurvature[i] = std::numeric_limits<double>::infinity();
//                    continue;
//                }
//            }
//
//
//            int iminus = i-maxStep;
//            int iplus = i+maxStep;
//            pminus = vecContourPoints[iminus < 0 ? iminus + vecContourPoints.size() : iminus];
//            pplus = vecContourPoints[iplus > vecContourPoints.size() ? iplus - vecContourPoints.size() : iplus];
//
//
//            f1stDerivative[0] =   (pplus[0] -        pminus[0]) / (iplus-iminus);
//            f1stDerivative[1] =   (pplus[1] -        pminus[1]) / (iplus-iminus);
//            f2ndDerivative[0] = (pplus[0] - 2*pos[0] + pminus[0]) / ((iplus-iminus)/2*(iplus-iminus)/2);
//            f2ndDerivative[1] = (pplus[1] - 2*pos[1] + pminus[1]) / ((iplus-iminus)/2*(iplus-iminus)/2);
//
//            double curvature2D;
//            double divisor = f1stDerivative[0]*f1stDerivative[0] + f1stDerivative[1]*f1stDerivative[1];
//            if ( std::abs(divisor) > 10e-8 )
//                {
//                    curvature2D =  std::abs(f2ndDerivative[1]*f1stDerivative[0] - f2ndDerivative[0]*f1stDerivative[1]) /
//                    pow(divisor, 3.0/2.0 )  ;
//                }
//            else
//                {
//                    curvature2D = std::numeric_limits<double>::infinity();
//                }
//
//                vecCurvature[i] = curvature2D;
//
//
//        }
//        return vecCurvature;
//}
