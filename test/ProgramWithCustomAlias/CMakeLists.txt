cmake_minimum_required(VERSION 3.5)

project(test)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

build_program(
  NAME main
  ALIAS temp
  SRCS main.cpp
)
