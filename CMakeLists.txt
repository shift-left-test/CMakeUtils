# Copyright (c) 2020 LG Electronics Inc.
# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.5.1)

project(CMakeUtils NONE)

# Install the scripts into the currently running cmake Modules directory
install(FILES scripts/CMakeUtils.cmake DESTINATION ${CMAKE_ROOT}/Modules)
install(FILES scripts/FindGMock.cmake DESTINATION ${CMAKE_ROOT}/Modules)
