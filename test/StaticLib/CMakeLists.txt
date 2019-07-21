cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_static_library(
  NAME a
  SRCS a.cpp
)
