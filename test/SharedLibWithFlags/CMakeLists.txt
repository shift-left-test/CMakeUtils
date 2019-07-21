cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

build_shared_library(NAME c SRCS c.c CFLAGS "C" CPPFLAGS "CPP")
build_shared_library(NAME cpp SRCS cpp.cpp CXXFLAGS "CXX" CPPFLAGS "CPP")
