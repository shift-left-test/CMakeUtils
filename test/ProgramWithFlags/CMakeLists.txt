cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_program(
  NAME main
  SRCS c.c cpp.cpp
  CFLAGS "C"
  CPPFLAGS "CPP"
  CXXFLAGS "CXX"
  PRIVATE_HEADERS ${CMAKE_SOURCE_DIR}
)
