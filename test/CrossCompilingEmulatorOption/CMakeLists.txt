cmake_minimum_required(VERSION 3.5)

project(test)

# Enforce the option
set(CMAKE_CROSSCOMPILING_EMULATOR "qemu-unknown")

include(CMakeUtils)

build_test_program(
  NAME MyTest
  SRCS MyTest.cpp
)

enable_testing()
enable_static_analysis()
