cmake_minimum_required(VERSION 3.5)

project(test VERSION 1.0.0)

include(CMakeUtils)

set_default_build_type(Debug)

enable_testing()

add_subdirectory(module)
add_subdirectory(test)

build_debian_package(MAINTAINER "john <john@doe>")
