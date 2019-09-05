cmake_minimum_required(VERSION 3.5)

project(test)

# Pretend that the cross compilation environment has been set
set(CMAKE_CROSSCOMPILING ON)

include(CMakeUtils)

enable_testing()
enable_test_coverage()

build_test_program(
  NAME MyTest
  SRCS MyTest.cpp
)

