cmake_minimum_required(VERSION 3.5)

project(test)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

build_program(
  NAME main
  SRCS main.cpp
  PRIVATE_HEADERS "${CMAKE_CURRENT_LIST_DIR}/include"
)
