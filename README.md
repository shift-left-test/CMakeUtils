# CMakeUtils

A set of CMake macro extensions for a C/C++ project

### Requiurements

- python 2.7 or above
- pytest
- gcc/g++
- CMake 3.5.0 or above
- make

### How to install prerequisites

    $ sudo apt-get install python cmake build-essential python-pytest

### How to run the tests

    $ ./runtest.sh

### Build module recipes

Here are examples of how to use the script to build programs and libraries from source.

To create a program:
```cmake
build_program(
  NAME <name>
  PREFIX <prefix>
  SUFFIX <suffix>
  SRCS <list of source files>
  LIBS <list of libraries>
  PRIVATE_HEADERS <list of private header paths>
  CFLAGS <list of C compilation flags>
  CPPFLAGS <list of pre-processing flags>
  CXXFLAGS <list of CXX compilation flags>
)
```

To create a static library:
```cmake
build_static_library(
  NAME <name>
  PREFIX <prefix>
  SUFFIX <suffix>
  SRCS <list of source files>
  LIBS <list of libraries>
  PRIVATE_HEADERS <list of private header paths>
  PUBLIC_HEADERS <list of public header paths>
  CFLAGS <list of C compilation flags>
  CPPFLAGS <list of pre-processing flags>
  CXXFLAGS <list of CXX compilation flags>
)
```

To create a shared library:
```cmake
build_shared_library(
  NAME <name>
  PREFIX <prefix>
  SUFFIX <suffix>
  VERSION <verion number>
  SRCS <list of source files>
  LIBS <list of libraries>
  PRIVATE_HEADERS <list of private header paths>
  PUBLIC_HEADERS <list of public header paths>
  CFLAGS <list of C compilation flags>
  CPPFLAGS <list of pre-processing flags>
  CXXFLAGS <list of CXX compilation flags>
)
```

To create a unit test program:
```cmake
build_test_program(
  NAME <name>
  PREFIX <prefix>
  SUFFIX <suffix>
  SRCS <list of source files>
  LIBS <list of libraries>
  PRIVATE_HEADERS <list of private header paths>
  PUBLIC_HEADERS <list of public header paths>
  CFLAGS <list of C compilation flags>
  CPPFLAGS <list of pre-processing flags>
  CXXFLAGS <list of CXX compilation flags>
)
```

To create a debian package (This function call should be located at the end of the top-level CMakeLists.txt) :
```cmake
build_debian_package(
  MAINTAINER <maintainer>
  CONTACT <contact information>
  HOMEPAGE <homepage address>
  VENDOR <vendor>
  DESCRITPION <description>
)
```

To enable static analysis checkers (This function call should be located at the end of the top-level CMakeLists.txt) :
```cmake
# implicitly enable all checkers
enable_static_analysis(ALL)

# or explicitly enable checkers
enable_static_analysis(CPPLINT CPPCHECK CLANG-TIDY CLANG-FORMAT)
```

### Licenses

This project source code is available under MIT license. See [LICENSE](LICENSE).