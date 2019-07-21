cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_static_library(
  NAME a
  SRCS a.cpp
  PUBLIC_HEADERS "${CMAKE_SOURCE_DIR}/include"
)

build_static_library(
  NAME b
  SRCS b.cpp
  LIBS a
)
