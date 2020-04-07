cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

set_default_build_type(Debug)

configure_file(${CMAKE_SOURCE_DIR}/Doxyfile.in ${CMAKE_SOURCE_DIR}/Doxyfile @ONLY)

enable_doxygen()

build_program(
  NAME main
  SRCS main.cpp
)
