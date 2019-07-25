cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_program(
  NAME main
  SRCS main.cpp
  PUBLIC_HEADERS "${CMAKE_CURRENT_LIST_DIR}/include"
)
