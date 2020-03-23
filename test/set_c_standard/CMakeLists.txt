cmake_minimum_required(VERSION 3.5)

project(test)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

set_c_standard(99)

build_program(
  NAME main
  SRCS main.c
)
