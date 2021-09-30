cmake_minimum_required(VERSION 3.10)

project(main)

include(CMakeUtils)

set_default_build_type(Debug)

enable_static_analysis()

build_program(
  NAME a.out
  SRCS main.cpp
)
