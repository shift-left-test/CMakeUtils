cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

set_default_build_type(Debug)

build_test_program(
  NAME MyTest
  SRCS FirstTest.cpp SecondTest.cpp
)

enable_testing()
enable_static_analysis()
