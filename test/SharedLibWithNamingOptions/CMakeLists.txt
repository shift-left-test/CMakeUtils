cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

set_default_build_type(Debug)

build_shared_library(
  NAME a
  PREFIX xxx
  SUFFIX .library
  VERSION 1.2.3
  SRCS a.cpp
)
