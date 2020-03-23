cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

set_default_build_type(Debug)

enable_testing()
enable_test_coverage(BRANCH)

build_test_program(
  NAME MyTest
  SRCS MyTest.cpp
)

enable_static_analysis()
