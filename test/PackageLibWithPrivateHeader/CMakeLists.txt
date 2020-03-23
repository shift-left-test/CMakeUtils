cmake_minimum_required(VERSION 3.5)

project(test VERSION 1.0.0)

include(CMakeUtils)

set_default_build_type(Debug)

build_shared_library(
  NAME a
  SRCS a.cpp
  PRIVATE_HEADERS "${CMAKE_CURRENT_LIST_DIR}/include"
)

build_debian_package(MAINTAINER "john <john@doe>")
