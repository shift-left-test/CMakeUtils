cmake_minimum_required(VERSION 3.5)

project(test)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

build_test_program(
  NAME MyTest
  SRCS FirstTest.cpp SecondTest.cpp
)

enable_testing()
enable_static_analysis()
