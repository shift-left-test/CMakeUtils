cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)

project(cpp-project VERSION 1.0.0)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../scripts")
include(CMakeUtils)

# Set c++11 standard flags
set_cxx_standard(11)

enable_testing()

add_subdirectory(plus)
add_subdirectory(minus)
add_subdirectory(program)
add_subdirectory(test)
