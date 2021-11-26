# Copyright (c) 2019 LG Electronics Inc.
# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)

project(cpp-project VERSION 1.0.0)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../scripts")
include(CMakeUtils)

# Set c++11 standard flags
set_cxx_standard(11)

enable_static_analysis(NO_IWYU)
enable_testing()
enable_test_coverage()

enable_doxygen()

add_all_subdirectories()
