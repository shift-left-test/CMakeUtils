cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_program(
  NAME a
  SRCS a.cpp
  PUBLIC_HEADERS "${CMAKE_SOURCE_DIR}/include"
)

build_program(
  NAME b
  SRCS b.cpp
  LIBS a
)
