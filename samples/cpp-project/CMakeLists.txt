cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)

project(cpp-project VERSION 1.0.0)

# Set c++11 standard options
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../scripts")
include(CMakeUtils)

enable_testing()

add_subdirectory(plus)
add_subdirectory(minus)
add_subdirectory(program)
add_subdirectory(test)
