cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

set_default_build_type(DebugWithRelInfo)

build_program(
  NAME main
  SRCS main.cpp
)
