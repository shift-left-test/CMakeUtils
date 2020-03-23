cmake_minimum_required(VERSION 3.5)

project(test VERSION 0.0.1)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

build_program(
  NAME main
  SUFFIX .out
  SRCS main.cpp
)

build_debian_package(
  MAINTAINER "user <user@foo.bar>"
)
