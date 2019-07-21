cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

enable_testing()

build_test_program(
  NAME MyTest
  SRCS FirstTest.cpp SecondTest.cpp
)
