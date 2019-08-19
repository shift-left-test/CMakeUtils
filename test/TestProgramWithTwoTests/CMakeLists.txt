cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_test_program(
  NAME FirstTest
  SRCS FirstTest.cpp
)

build_test_program(
  NAME SecondTest
  SRCS SecondTest.cpp
)

enable_testing()
enable_static_analysis()
