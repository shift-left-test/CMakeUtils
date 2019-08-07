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

To create a simple program:
```cmake
build_program(
  NAME name
  SRCS source.cpp ...
)
```

To create a program with dependent libraries:
```cmake
build_program(
  NAME name
  SRCS source.cpp ...
  LIBS nameOfLibrary ...
)
```

To create a static library with compilation flags:
```cmake
build_static_library(
  NAME nameOfLibrary
  SRCS source.cpp ...
  CPPFLAGS CUSTOM_FLAG ...
)
```

To create a static library with private and public headers:
```cmake
build_static_library(
  NAME nameOfLibrary
  SRCS source.cpp ...
  CPPFLAGS CUSTOM_FLAG ...
  PRIVATE_HEADERS path/to/private/header/dir ...
  PUBLIC_HEADERS path/to/public/header/dir ...
)
```

To create a versioned shared library:
```cmake
build_shared_library(
  NAME nameOfLibrary
  SRCS source.cpp ...
  VERSION 1.0.0
  PUBLIC_HEADERS path/to/public/header/dir ...
)
```

To create a unit test program with dependent libraries:
```cmake
build_test_program(
  NAME testProgName
  SRCS unitTest.cpp ...
  LIBS nameOfLibrary ...
)
```

### Licenses

This project source code is available under MIT license. See [LICENSE](LICENSE).