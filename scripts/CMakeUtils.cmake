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

# Resolve absolute paths of the given files
function(absolute_paths VARIABLE)
  set(result "")
  foreach(path ${ARGN})
    get_filename_component(newpath ${path} ABSOLUTE BASE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
    list(APPEND result ${newpath})
  endforeach()
  set(${VARIABLE} ${result} PARENT_SCOPE)
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
  set(ALL_SOURCE_FILES ${ALL_SOURCE_FILES} ${CURRENT_SOURCE_FILES} PARENT_SCOPE)

  if(BUILD_PUBLIC_HEADERS OR BUILD_PRIVATE_HEADERS)
    target_include_directories(${BUILD_NAME}
      PUBLIC ${BUILD_PUBLIC_HEADERS}
      PRIVATE ${BUILD_PRIVATE_HEADERS})

    # Accumulate the headers for static analysis
    absolute_paths(CURRENT_HEADERS ${BUILD_PUBLIC_HEADERS} ${BUILD_PRIVATE_HEADERS})
    set(ALL_HEADER_DIRS ${ALL_HEADER_DIRS} ${CURRENT_HEADERS} PARENT_SCOPE)
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

  add_executable(${BUILD_NAME} ${BUILD_SRCS})

  # Accumulate the source files for static analysis
  absolute_paths(CURRENT_SOURCE_FILES ${BUILD_SRCS})
  set(ALL_SOURCE_FILES ${ALL_SOURCE_FILES} ${CURRENT_SOURCE_FILES} PARENT_SCOPE)

  if(BUILD_PUBLIC_HEADERS OR BUILD_PRIVATE_HEADERS)
    target_include_directories(${BUILD_NAME}
      PUBLIC ${BUILD_PUBLIC_HEADERS}
      PRIVATE ${BUILD_PRIVATE_HEADERS})

    # Accumulate the headers for static analysis
    absolute_paths(CURRENT_HEADERS ${BUILD_PUBLIC_HEADERS} ${BUILD_PRIVATE_HEADERS})
    set(ALL_HEADER_DIRS ${ALL_HEADER_DIRS} ${CURRENT_HEADERS} PARENT_SCOPE)
  endif()

  string(TOUPPER "${BUILD_TYPE}" BUILD_TYPE)

  if(BUILD_TYPE STREQUAL "TEST")
    find_package(Threads REQUIRED)
    find_package(GTest REQUIRED)
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

# Register the given static analysis checker if available
function(register_checker)
  set(oneValueArgs NAME DEPENDS)
  set(multiValueArgs PATHS NAMES OPTIONS FILES)
  cmake_parse_arguments(ARGS
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  find_program(${ARGS_NAME}_PROGRAM PATHS ${ARGS_PATHS} NAMES ${ARGS_NAMES})
  if(${ARGS_NAME}_PROGRAM)
    message(STATUS "Found ${ARGS_NAME} code checker: TRUE")
    add_custom_target(
      ${ARGS_NAME}
      COMMAND ${${ARGS_NAME}_PROGRAM} ${ARGS_OPTIONS} ${ARGS_FILES}
      COMMENT "Running ${ARGS_NAME}..."
    )
    add_dependencies(${ARGS_DEPENDS} ${ARGS_NAME})
  else()
    message(STATUS "Found ${ARGS_NAME} code checker: FALSE")
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
    file(GLOB_RECURSE foundFiles LIST_DIRECTORIES True "${directory}/*.h" "${directory}/*.hpp")
    list(APPEND result ${foundFiles})
  endforeach()
  set(${VARIABLE} ${result} PARENT_SCOPE)
endfunction()

# Enable the static analysis checkers
function(enable_static_analysis)
  set(options ALL CPPLINT CPPCHECK CLANG-TIDY CLANG-FORMAT)
  cmake_parse_arguments(ENABLE
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  add_custom_target(check)

  find_header_files(ALL_HEADER_FILES ${ALL_HEADER_DIRS})

  if(ENABLE_ALL OR ENABLE_CLANG-FORMAT)
    register_checker(
      NAME clang-format
      DEPENDS check
      PATHS /usr/bin
      NAMES clang-format
      OPTIONS -i -style=Google
      FILES ${ALL_HEADER_FILES} ${ALL_SOURCE_FILES}
      )
  endif()

  if(ENABLE_ALL OR ENABLE_CLANG-TIDY)
    register_checker(
      NAME clang-tidy
      DEPENDS check
      PATHS /usr/bin
      NAMES clang-tidy
      FILES ${ALL_SOURCE_FILES}
      )
  endif()

  if(ENABLE_ALL OR ENABLE_CPPLINT)
    register_checker(
      NAME cpplint
      DEPENDS check
      PATHS /usr/local/bin
      NAMES cpplint
      OPTIONS --quiet
      FILES ${ALL_HEADER_FILES} ${ALL_SOURCE_FILES}
      )
  endif()

  if(ENABLE_ALL OR ENABLE_CPPCHECK)
    prepend(INCLUDE_HEADER_DIRS "-I" ${ALL_HEADER_DIRS})
    register_checker(
      NAME cppcheck
      DEPENDS check
      PATHS /usr/bin
      NAMES cppcheck
      OPTIONS --enable=all --force --quiet --suppress=missingIncludeSystem ${INCLUDE_HEADER_DIRS}
      FILES ${ALL_HEADER_FILES} ${ALL_SOURCE_FILES}
      )
  endif()

endfunction()
