cmake_minimum_required(VERSION 3.5)

project(test)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

enable_doxygen()

build_program(
  NAME main
  SRCS main.cpp
)
