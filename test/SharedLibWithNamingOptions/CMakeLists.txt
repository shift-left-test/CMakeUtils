cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_shared_library(
  NAME a
  PREFIX xxx
  SUFFIX .library
  VERSION 1.2.3
  SRCS a.cpp
)
