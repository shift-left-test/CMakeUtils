cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

set_default_build_type(Debug)

build_shared_library(
  NAME a
  SRCS a.cpp
  PUBLIC_HEADERS "${CMAKE_CURRENT_LIST_DIR}/include"
)

build_shared_library(
  NAME b
  SRCS b.cpp
  LIBS a
)
