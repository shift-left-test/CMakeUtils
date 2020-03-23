cmake_minimum_required(VERSION 3.5)

project(test VERSION 0.0.1)

include(CMakeUtils)

set_default_build_type(Debug)

build_program(
  NAME main
  SUFFIX .out
  SRCS main.cpp
)

build_debian_package(
  MAINTAINER "user <user@foo.bar>"
)
