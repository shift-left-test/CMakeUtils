cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)

project(test)

set(CMAKE_BUILD_TYPE Debug)

include(CMakeUtils)

enable_testing()
enable_test_coverage()
add_all_subdirectories()
