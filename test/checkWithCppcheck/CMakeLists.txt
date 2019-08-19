cmake_minimum_required(VERSION 3.5)

project(test)

include(CMakeUtils)

enable_testing()

add_subdirectory(liba)
add_subdirectory(libb)
add_subdirectory(program)

enable_static_analysis(CPPCHECK)
