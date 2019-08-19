cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_static_library(
  NAME a
  SRCS liba/plus.cpp liba/minus.cpp
  PUBLIC_HEADERS liba/include
)

build_shared_library(
  NAME b
  SRCS libb/multiply.cpp libb/divide.cpp
  PUBLIC_HEADERS ${CMAKE_CURRENT_LIST_DIR}/libb/include
)

build_program(
  NAME program
  SUFFIX .out
  SRCS program/main.cpp
  LIBS a b
)

enable_testing()
enable_static_analysis()
