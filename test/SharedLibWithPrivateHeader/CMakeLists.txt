cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_shared_library(
  NAME a
  SRCS a.cpp
  PRIVATE_HEADERS "${CMAKE_CURRENT_LIST_DIR}/include"
)

build_program(
  NAME main
  SRCS main.cpp
  LIBS a::lib
)
