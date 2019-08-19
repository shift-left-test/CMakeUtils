cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_static_library(
  NAME Number
  SRCS Number.cpp
)

build_program(
  NAME program
  SUFFIX .out
  SRCS main.cpp
  LIBS Number
)

enable_testing()
enable_static_analysis(CLANG-TIDY)
