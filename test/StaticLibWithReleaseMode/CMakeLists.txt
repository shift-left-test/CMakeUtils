cmake_minimum_required(VERSION 3.5)

project(test)

set(CMAKE_BUILD_TYPE Release)

include(CMakeUtils)

build_static_library(
  NAME a
  SRCS a.cpp
)
