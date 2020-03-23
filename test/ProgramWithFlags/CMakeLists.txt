cmake_minimum_required(VERSION 3.5)

project(test)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

build_program(
  NAME main
  SRCS c.c cpp.cpp
  CFLAGS "C"
  CPPFLAGS "CPP"
  CXXFLAGS "CXX"
  PRIVATE_HEADERS ${CMAKE_CURRENT_LIST_DIR}
)
