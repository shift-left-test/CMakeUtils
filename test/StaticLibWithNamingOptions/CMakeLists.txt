cmake_minimum_required(VERSION 3.5)

project(test)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

build_static_library(
  NAME a
  PREFIX xxx
  SUFFIX .library
  VERSION 1.2.3
  SRCS a.cpp
)
