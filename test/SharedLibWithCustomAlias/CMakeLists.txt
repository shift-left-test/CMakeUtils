cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_shared_library(
  NAME a
  ALIAS c
  SRCS a.cpp
  PUBLIC_HEADERS "${CMAKE_SOURCE_DIR}/include"
)

build_program(
  NAME main
  SRCS main.cpp
  LIBS c::lib
)
