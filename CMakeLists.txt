cmake_minimum_required(VERSION 3.6)
project (contours)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  message("-- Prefix initialized to default")
  set (CMAKE_INSTALL_PREFIX "~/opt" CACHE PATH "default install path" FORCE )
else()
  message("-- Prefix set by user")
endif()    

add_subdirectory(cpp)
add_subdirectory(matlab)

