cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

set_default_build_type(Debug)

build_shared_library(
  NAME a
  ALIAS c
  SRCS a.cpp
  PUBLIC_HEADERS "${CMAKE_CURRENT_LIST_DIR}/include"
)

build_program(
  NAME main
  SRCS main.cpp
  LIBS c::lib
)
