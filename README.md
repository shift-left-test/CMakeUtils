# CMakeUtils

A set of CMake macro extensions for a C/C++ project


### Requiurements

- python 2.7 or above
- pytest
- gcc/g++
- CMake 3.1.3 or above
- make
- doxygen


### How to install prerequisites

    $ sudo apt-get install python cmake build-essential python-pip python-pytest doxygen graphviz
    $ pip install gcovr


### How to run the tests

    $ py.test


### How to configure CMakeLists.txt files under the test directory

You may run the following command at the top-level directory

    $ cmake -S . -B <directory> -DCMAKE_MODULE_PATH=`pwd`/scripts


### How to create new predefined C++ project

    $ ./bootstrap.py -d <DIRECTORY> [-m <MAINTAINER> -p <PROJECT>]


### How to install googletest (gtest, gmock) libraries

    $ sudo apt-get install cmake googletest g++
    $ mkdir build ; cd build
    $ cmake /usr/src/googletest/
    $ make -j
    $ sudo find . -name "*.a" -exec cp {} /usr/lib \;


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
  COMPILE_OPTIONS <list of compilation flags>
  LINK_OPTIONS <list of linker flags>
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
  COMPILE_OPTIONS <list of compilation flags>
  LINK_OPTIONS <list of linker flags>
)
```

To create an external static library:
```cmake
build_external_static_library(
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
  COMPILE_OPTIONS <list of compilation flags>
  LINK_OPTIONS <list of linker flags>
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
  COMPILE_OPTIONS <list of compilation flags>
  LINK_OPTIONS <list of linker flags>
)
```

To create an external shared library:
```cmake
build_external_shared_library(
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
  COMPILE_OPTIONS <list of compilation flags>
  LINK_OPTIONS <list of linker flags>
)
```

To create a header-only library:
```cmake
build_interface_library(
  NAME <name>
  LIBS <list of libraries>
  PRIVATE_HEADERS <list of private header paths>
  PUBLIC_HEADERS <list of public header paths>
  CFLAGS <list of C compilation flags>
  CPPFLAGS <list of pre-processing flags>
  CXXFLAGS <list of CXX compilation flags>
  COMPILE_OPTIONS <list of compilation flags>
  LINK_OPTIONS <list of linker flags>
)
```

To create an external header-only library:
```cmake
build_external_interface_library(
  NAME <name>
  LIBS <list of libraries>
  PRIVATE_HEADERS <list of private header paths>
  PUBLIC_HEADERS <list of public header paths>
  CFLAGS <list of C compilation flags>
  CPPFLAGS <list of pre-processing flags>
  CXXFLAGS <list of CXX compilation flags>
  COMPILE_OPTIONS <list of compilation flags>
  LINK_OPTIONS <list of linker flags>
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
  COMPILE_OPTIONS <list of compilation flags>
  LINK_OPTIONS <list of linker flags>
)
```

To create a debian package (This function call should be located at the end of the top-level CMakeLists.txt):
```cmake
build_debian_package(
  MAINTAINER <maintainer>
  CONTACT <contact information>
  HOMEPAGE <homepage address>
  VENDOR <vendor>
  DESCRITPION <description>
)
```

To enable static analysis checkers:
```cmake
enable_static_analysis()
```

From 1.4.0, static analysis checkers are not enabled by default. You should explicitly define checkers to use.
For instance, the following command enables all of the static analysis checkers if available.

```cmake
enable_static_analysis(clang-tidy cppcheck cpplint iwyu lwyu)
```

You may find useful information about the static analysis tools with the following links:

- clang-tidy: https://clang.llvm.org/extra/clang-tidy/
- cppcheck: https://cppcheck.sourceforge.io/
- cpplint: https://github.com/cpplint/cpplint
- iwyu: https://include-what-you-use.org/
- lwyu: https://cmake.org/cmake/help/latest/prop_tgt/LINK_WHAT_YOU_USE.html


To enable test coverage report (requires gcovr):
```cmake
enable_test_coverage()

# or for branch coverage
enable_test_coverage(BRANCH)
```

To enable doxygen generator:
```cmake
enable_doxygen()
```


### Licenses

This project source code is available under MIT license. See [LICENSE](LICENSE).