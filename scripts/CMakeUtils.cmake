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
