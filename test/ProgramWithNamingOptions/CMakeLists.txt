cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

set_default_build_type(Debug)

build_program(
  NAME main
  PREFIX xxx
  SUFFIX .exe
  VERSION 1.2.3
  SRCS main.cpp
)
