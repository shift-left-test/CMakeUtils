cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)

project(test)

include(CMakeUtils)

set_default_build_type(Debug)

enable_testing()
enable_test_coverage()
add_all_subdirectories()
