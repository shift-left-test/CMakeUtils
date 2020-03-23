cmake_minimum_required(VERSION 3.5)

project(test)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

set_cxx_standard(11)

build_static_library(
  NAME plus
  SRCS src/plus.cpp
  PUBLIC_HEADERS include
)

build_program(
  NAME main
  SRCS main.cpp
  LIBS plus
  LINK_OPTIONS -L/test-path
)
