# MIT License
#
# Copyright (c) 2019 Sung Gon Kim
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

include(CMakeParseArguments)
include(GNUInstallDirs)

# Save the compile commands as a file
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set debug as the default build type
if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
  message(STATUS "Build Type: Debug (default)")
  set(CMAKE_BUILD_TYPE Debug)
else()
  message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
endif()

# Set code coverage options to default flags
set(CMAKE_C_FLAGS_DEBUG "-O0 -g -fprofile-arcs -ftest-coverage")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g -fprofile-arcs -ftest-coverage")

# Macro to set C standard flags
macro(set_c_standard VERSION)
  set(CMAKE_C_STANDARD_REQUIRED ON)
  set(CMAKE_C_STANDARD ${VERSION})
  set(CMAKE_C_EXTENSIONS OFF)
endmacro()

# Macro to set CXX standard flags
macro(set_cxx_standard VERSION)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_STANDARD ${VERSION})
  set(CMAKE_CXX_EXTENSIONS OFF)
endmacro()

# Macro to include all CMakeLists.txt under subdirectories.
macro(add_all_subdirectories)
  file(GLOB_RECURSE allListFiles LIST_DIRECTORIES False "CMakeLists.txt")
  list(REMOVE_ITEM allListFiles "${CMAKE_SOURCE_DIR}/CMakeLists.txt")
  foreach(listFile ${allListFiles})
    get_filename_component(listDirectory ${listFile} DIRECTORY)
    add_subdirectory(${listDirectory})
  endforeach()
endmacro()

# Resolve absolute paths of the given files
function(absolute_paths VARIABLE)
  set(result "")
  foreach(path ${ARGN})
    get_filename_component(newpath ${path} ABSOLUTE BASE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
    list(APPEND result ${newpath})
  endforeach()
  set(${VARIABLE} ${result} PARENT_SCOPE)
endfunction()

# Prepare variables for static analysis
set_property(GLOBAL PROPERTY ALL_SOURCE_FILES)
set_property(GLOBAL PROPERTY ALL_HEADER_DIRS)

# Add global property
function(add_global_property VARIABLE)
  get_property(temp GLOBAL PROPERTY ${VARIABLE})
  foreach(arg ${ARGN})
    set(temp ${temp} ${arg})
  endforeach()
  set_property(GLOBAL PROPERTY ${VARIABLE} ${temp})
endfunction()

# An helper function to build libraries
function(build_library)
  set(oneValueArgs TYPE NAME PREFIX SUFFIX VERSION ALIAS)
  set(multiValueArgs SRCS LIBS PUBLIC_HEADERS PRIVATE_HEADERS CFLAGS CPPFLAGS CXXFLAGS)
  cmake_parse_arguments(BUILD
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  string(TOUPPER "${BUILD_TYPE}" BUILD_TYPE)
  add_library(${BUILD_NAME} ${BUILD_TYPE} ${BUILD_SRCS})

  # Accumulate the source files for static analysis
  absolute_paths(CURRENT_SOURCE_FILES ${BUILD_SRCS})
  add_global_property(ALL_SOURCE_FILES ${CURRENT_SOURCE_FILES})

  if(BUILD_PUBLIC_HEADERS OR BUILD_PRIVATE_HEADERS)
    target_include_directories(${BUILD_NAME}
      PUBLIC ${BUILD_PUBLIC_HEADERS}
      PRIVATE ${BUILD_PRIVATE_HEADERS})

    # Accumulate the headers for static analysis
    absolute_paths(CURRENT_HEADERS ${BUILD_PUBLIC_HEADERS} ${BUILD_PRIVATE_HEADERS})
    add_global_property(ALL_HEADER_DIRS ${CURRENT_HEADERS})
  endif()

  install(
    TARGETS ${BUILD_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_OLDINCLUDEDIR})

  if(BUILD_ALIAS)
    add_library(${BUILD_ALIAS}::lib ALIAS ${BUILD_NAME})
  else()
    add_library(${BUILD_NAME}::lib ALIAS ${BUILD_NAME})
  endif()

  if(BUILD_PREFIX)
    set_target_properties(${BUILD_NAME} PROPERTIES PREFIX ${BUILD_PREFIX})
  endif()

  if(BUILD_SUFFIX)
    set_target_properties(${BUILD_NAME} PROPERTIES SUFFIX ${BUILD_SUFFIX})
  endif()

  if(BUILD_VERSION)
    string(REGEX REPLACE "([0-9]+).[0-9]+.[0-9]+" "\\1" BUILD_VERSION_MAJOR
      ${BUILD_VERSION})
    set_target_properties(${BUILD_NAME} PROPERTIES
      VERSION ${BUILD_VERSION}
      SOVERSION ${BUILD_VERSION_MAJOR})
  endif()

  if(BUILD_CFLAGS)
    target_compile_definitions(${BUILD_NAME} PUBLIC ${BUILD_CFLAGS})
  endif()

  if(BUILD_CPPFLAGS)
    target_compile_definitions(${BUILD_NAME} PUBLIC ${BUILD_CPPFLAGS})
  endif()

  if(BUILD_CXXFLAGS)
    target_compile_definitions(${BUILD_NAME} PUBLIC ${BUILD_CXXFLAGS})
  endif()

  if(BUILD_LIBS)
    target_link_libraries(${BUILD_NAME} PUBLIC ${BUILD_LIBS})
  endif()
endfunction()

macro(build_shared_library)
  build_library(TYPE shared ${ARGN})
endmacro()

macro(build_static_library)
  build_library(TYPE static ${ARGN})
endmacro(build_static_library)


# An helper function to build executables
function(build_executable)
  set(oneValueArgs TYPE NAME PREFIX SUFFIX VERSION ALIAS)
  set(multiValueArgs SRCS LIBS PUBLIC_HEADERS PRIVATE_HEADERS CFLAGS CPPFLAGS CXXFLAGS)
  cmake_parse_arguments(BUILD
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  string(TOUPPER "${BUILD_TYPE}" BUILD_TYPE)

  if(BUILD_TYPE STREQUAL "TEST" AND CMAKE_CROSSCOMPILING)
    message(STATUS "Skipped: ${BUILD_NAME}")
    return()
  endif()

  add_executable(${BUILD_NAME} ${BUILD_SRCS})

  # Accumulate the source files for static analysis
  absolute_paths(CURRENT_SOURCE_FILES ${BUILD_SRCS})
  add_global_property(ALL_SOURCE_FILES ${CURRENT_SOURCE_FILES})

  if(BUILD_PUBLIC_HEADERS OR BUILD_PRIVATE_HEADERS)
    target_include_directories(${BUILD_NAME}
      PUBLIC ${BUILD_PUBLIC_HEADERS}
      PRIVATE ${BUILD_PRIVATE_HEADERS})

    # Accumulate the headers for static analysis
    absolute_paths(CURRENT_HEADERS ${BUILD_PUBLIC_HEADERS} ${BUILD_PRIVATE_HEADERS})
    add_global_property(ALL_HEADER_DIRS ${CURRENT_HEADERS})
  endif()

  if(BUILD_TYPE STREQUAL "TEST")
    find_package(Threads REQUIRED)
    find_package(GTest REQUIRED)

    set_target_properties(${BUILD_NAME} PROPERTIES
      CXX_STANDARD 11
      CXX_STANDARD_REQUIRED ON
      CXX_EXTENSIONS OFF
    )

    target_include_directories(${BUILD_NAME} PRIVATE ${GTEST_INCLUDE_DIRS})
    target_link_libraries(${BUILD_NAME}
      PRIVATE ${GTEST_BOTH_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})
    gtest_add_tests(${BUILD_NAME} "" AUTO)
  else()
    install(
      TARGETS ${BUILD_NAME}
      RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
  endif()

  if(BUILD_PREFIX)
    set_target_properties(${BUILD_NAME} PROPERTIES PREFIX ${BUILD_PREFIX})
  endif()

  if(BUILD_SUFFIX)
    set_target_properties(${BUILD_NAME} PROPERTIES SUFFIX ${BUILD_SUFFIX})
  endif()

  if(BUILD_VERSION)
    message(WARNING "Unsupported variable VERSION found at ${CMAKE_CURRENT_LIST_FILE}")
  endif()

  if(BUILD_ALIAS)
    message(WARNING "Unsupported variable ALIAS found at ${CMAKE_CURRENT_LIST_FILE}")
  endif()

  if(BUILD_CFLAGS)
    target_compile_definitions(${BUILD_NAME} PUBLIC ${BUILD_CFLAGS})
  endif()

  if(BUILD_CPPFLAGS)
    target_compile_definitions(${BUILD_NAME} PUBLIC ${BUILD_CPPFLAGS})
  endif()

  if(BUILD_CXXFLAGS)
    target_compile_definitions(${BUILD_NAME} PUBLIC ${BUILD_CXXFLAGS})
  endif()

  if(BUILD_LIBS)
    target_link_libraries(${BUILD_NAME} PUBLIC ${BUILD_LIBS})
  endif()

endfunction()

macro(build_program)
  build_executable(TYPE program ${ARGN})
endmacro()

macro(build_test_program)
  build_executable(TYPE test ${ARGN})
endmacro()

# An helper function to manage header-only interfaces
function(build_interface)
  set(oneValueArgs NAME ALIAS)
  set(multiValueArgs SRCS LIBS PUBLIC_HEADERS PRIVATE_HEADERS CFLAGS CPPFLAGS CXXFLAGS)
  cmake_parse_arguments(BUILD
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  add_library(${BUILD_NAME} INTERFACE)

  # Accumulate the source files for static analysis
  absolute_paths(CURRENT_SOURCE_FILES ${BUILD_SRCS})
  add_global_property(ALL_SOURCE_FILES ${CURRENT_SOURCE_FILES})
  
  if(BUILD_PUBLIC_HEADERS OR BUILD_PRIVATE_HEADERS)
    target_include_directories(${BUILD_NAME}
      INTERFACE ${BUILD_PUBLIC_HEADERS} ${BUILD_PRIVATE_HEADERS})
    
    # Accumulate the headers for static analysis
    absolute_paths(CURRENT_HEADERS ${BUILD_PUBLIC_HEADERS} ${BUILD_PRIVATE_HEADERS})
    add_global_property(ALL_HEADER_DIRS ${CURRENT_HEADERS})
  endif()

  install(
    TARGETS ${BUILD_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_OLDINCLUDEDIR})

  if(BUILD_ALIAS)
    add_library(${BUILD_ALIAS}::lib ALIAS ${BUILD_NAME})
  else()
    add_library(${BUILD_NAME}::lib ALIAS ${BUILD_NAME})
  endif()

  if(BUILD_CFLAGS)
    target_compile_definitions(${BUILD_NAME} INTERFACE ${BUILD_CFLAGS})
  endif()
  
  if(BUILD_CPPFLAGS)
    target_compile_definitions(${BUILD_NAME} INTERFACE ${BUILD_CPPFLAGS})
  endif()
  
  if(BUILD_CXXFLAGS)
    target_compile_definitions(${BUILD_NAME} INTERFACE ${BUILD_CXXFLAGS})
  endif()
  
  if(BUILD_LIBS)
    target_link_libraries(${BUILD_NAME} INTERFACE ${BUILD_LIBS})
  endif()
endfunction()


function(build_debian_package)
  set(oneValueArgs MAINTAINER CONTACT HOMEPAGE VENDOR DESCRIPTION)
  cmake_parse_arguments(PKG
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  set(CPACK_GENERATOR DEB)

  if(PKG_MAINTAINER)
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER ${PKG_MAINTAINER})
  endif()

  if(PKG_CONTACT)
    set(CPAKC_DEBIAN_PACKAGE_CONTACT ${PKG_CONTACT})
  endif()

  if(PKG_HOMEPAGE)
    set(CPACK_DEBIAN_PACKAGE_HOMEPAGE ${PKG_HOMEPAGE})
  endif()

  set(CPACK_PACKAGE_NAME ${PROJECT_NAME})

  if(PKG_VENDOR)
    set(CPACK_PACKAGE_VENDOR ${PKG_VENDOR})
  endif()

  set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})

  if(PKG_SUMMARY)
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PKG_SUMMARY})
  endif()

  if(EXISTS "${CMAKE_SOURCE_DIR}/LICENSE")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
  elseif(EXISTS "${CMAKE_SOURCE_DIR}/LICENSE.md")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE.md")
  endif()

  if(NOT CPACK_DEBIAN_PACKAGE_ARCHITECTURE)
    find_program(DPKG_PATH dpkg)
    if(NOT DPKG_PATH)
      set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE i386)
    else()
      execute_process(
	COMMAND "${DPKG_PATH}" --print-architecture
	OUTPUT_VARIABLE CPACK_DEBIAN_PACKAGE_ARCHITECTURE
	OUTPUT_STRIP_TRAILING_WHITESPACE
	)
    endif()
  endif()

  set(CPACK_PACKAGE_FILE_NAME
    "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")

  include(CPack)
endfunction()

# Register the given program if available
function(register_program)
  set(oneValueArgs NAME DEPENDS)
  set(multiValueArgs PATHS NAMES OPTIONS FILES)
  cmake_parse_arguments(ARGS
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  find_program(${ARGS_NAME}_PROGRAM PATHS ${ARGS_PATHS} NAMES ${ARGS_NAMES})
  if(${ARGS_NAME}_PROGRAM)
    message(STATUS "Found ${ARGS_NAME} program: TRUE")
    add_custom_target(
      ${ARGS_NAME}
      COMMAND ${${ARGS_NAME}_PROGRAM} ${ARGS_OPTIONS} ${ARGS_FILES}
      COMMENT "Running ${ARGS_NAME}..."
    )
    add_dependencies(${ARGS_DEPENDS} ${ARGS_NAME})
  else()
    message(STATUS "Found ${ARGS_NAME} program: FALSE")
  endif()

endfunction()

# Prepend the given prefix to each of the strings
function(prepend VARIABLE PREFIX)
  set(result "")
  foreach(value ${ARGN})
    list(APPEND result ${PREFIX}/${value})
  endforeach()
  set(${VARIABLE} ${result} PARENT_SCOPE)
endfunction()

function(find_header_files VARIABLE)
  set(result "")
  foreach(directory ${ARGN})
    file(GLOB_RECURSE foundFiles LIST_DIRECTORIES False "${directory}/*.h" "${directory}/*.hpp")
    list(APPEND result ${foundFiles})
  endforeach()
  set(${VARIABLE} ${result} PARENT_SCOPE)
endfunction()


# Enable the static analysis checkers
function(enable_static_analysis)
  set(options ALL CPPLINT CPPCHECK CLANG-TIDY)
  cmake_parse_arguments(ENABLE
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  add_custom_target(check)

  get_property(SOURCE_FILES GLOBAL PROPERTY ALL_SOURCE_FILES)
  get_property(HEADER_DIRS GLOBAL PROPERTY ALL_HEADER_DIRS)

  find_header_files(HEADER_FILES ${HEADER_DIRS})

  if(ENABLE_ALL OR ENABLE_CLANG-TIDY)
    register_program(
      NAME clang-tidy
      DEPENDS check
      PATHS /usr/bin
      NAMES clang-tidy
      OPTIONS -p=${CMAKE_BINARY_DIR}
      FILES ${SOURCE_FILES}
      )
  endif()

  if(ENABLE_ALL OR ENABLE_CPPLINT)
    register_program(
      NAME cpplint
      DEPENDS check
      PATHS /usr/local/bin $ENV{HOME}/.local/bin
      NAMES cpplint
      OPTIONS --quiet
      FILES ${HEADER_FILES} ${SOURCE_FILES}
      )
  endif()

  if(ENABLE_ALL OR ENABLE_CPPCHECK)
    prepend(INCLUDE_HEADER_DIRS "-I" ${HEADER_DIRS})
    register_program(
      NAME cppcheck
      DEPENDS check
      PATHS /usr/bin
      NAMES cppcheck
      OPTIONS --enable=all --force --quiet --suppress=missingIncludeSystem ${INCLUDE_HEADER_DIRS}
      FILES ${HEADER_FILES} ${SOURCE_FILES}
      )
  endif()
endfunction()

# Enable gcovr for test coverage
function(enable_test_coverage)
  set(options BRANCH_COVERAGE)
  cmake_parse_arguments(ENABLE
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  add_custom_target(coverage)

  if(ENABLE_BRANCH_COVERAGE)
    set(GCOVR_BRANCH_OPTION "-b")
  endif()

  register_program(
    NAME gcovr
    DEPENDS coverage
    PATHS /usr/local/bin $ENV{HOME}/.local/bin
    NAMES gcovr
    OPTIONS ${GCOVR_BRANCH_OPTION} -s -r ${CMAKE_SOURCE_DIR} --object-directory ${CMAKE_BINARY_DIR}
    FILES ""
    )
endfunction()
