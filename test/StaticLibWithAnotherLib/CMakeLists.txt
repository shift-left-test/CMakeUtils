cmake_minimum_required(VERSION 3.5)

project(test)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

build_static_library(
  NAME a
  SRCS a.cpp
  PUBLIC_HEADERS "${CMAKE_CURRENT_LIST_DIR}/include"
)

build_static_library(
  NAME b
  SRCS b.cpp
  LIBS a
)
