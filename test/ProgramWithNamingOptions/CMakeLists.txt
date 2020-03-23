cmake_minimum_required(VERSION 3.5)

project(test)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

build_program(
  NAME main
  PREFIX xxx
  SUFFIX .exe
  VERSION 1.2.3
  SRCS main.cpp
)
