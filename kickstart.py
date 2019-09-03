#!/usr/bin/python
#-*- coding: utf-8 -*-

import argparse
import datetime
import urllib2
import getpass
import subprocess
import os
import shutil
import sys


GITIGNORE_URL = "https://www.gitignore.io/api/c,vim,c++,gcov,cmake,linux,python"

GITIGNORE_PATCH = """
CPackConfig.cmake
CPackSourceConfig.cmake
*.deb
_CPack_Packages/
"""

LICENSE = """MIT License

Copyright (c) {YEAR} {MAINTAINER}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

README_MD = """# {PROJECT}

This is {PROJECT}


### Requirements

* C++ compiler (c++11 supported)
* CMake 3.5.1 or above
* Google Test Framework
* gcovr


### How to build from source

    $ cmake .
    $ make all
    $ make check
    $ make test
    $ make coverage
    $ make package


### Licenses

The project source code is available under MIT license. See [LICENSE](LICENSE).
"""

ROOT_CMAKELISTS = """cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)

project({PROJECT} VERSION 1.0.0)

set(CMAKE_MODULE_PATH ${{CMAKE_SOURCE_DIR}}/scripts)
include(CMakeUtils)

set_cxx_standard(11)

enable_testing()
enable_test_coverage()
add_all_subdirectories()
enable_static_analysis(ALL)
build_debian_package(MAINTAINER {MAINTAINER})

"""

TEST_CMAKELISTS = """build_test_program(
  NAME {PROJECT}Test
  SUFFIX .exe
  SRCS SampleTest.cpp
)
"""

TEST_CPP = """/*
  MIT License

  Copyright (c) {YEAR} {MAINTAINER}

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*/

#include <gtest/gtest.h>

class SampleTest : public ::testing::Test {{
}};

TEST_F(SampleTest, test1) {{
  EXPECT_EQ(1, 1);
}}
"""

BUILD_SH = """#!/bin/bash
cmake .
make all
make check
make test
make coverage
make package
"""


def runCommand(command):
    print "Run: %s ..." % command
    proc = subprocess.Popen(command, shell = True)
    return proc.communicate()

def initGit(path):
    print "Create new directory at %s ..." % path
    if os.path.exists(path):
        raise IOError("Directory already exists: %s " % path)
    os.makedirs(path)
    runCommand("git init %s" % path)

def readFile(path):
    with open(path, 'r') as f:
        return f.read()

def appendToFile(path, data):
    print "Append to %s ..." % path
    if not os.path.exists(os.path.dirname(path)):
        os.makedirs(os.path.dirname(path))
    with open(path, 'a') as f:
        f.write(data)

def writeToFile(path, data):
    print "Write to %s ..." % path
    if not os.path.exists(os.path.dirname(path)):
        os.makedirs(os.path.dirname(path))
    with open(path, 'w') as f:
        f.write(data)


def copyFile(src, dest):
    print "Copy %s to %s ..." % (src, dest)
    if not os.path.exists(os.path.dirname(dest)):
        os.makedirs(os.path.dirname(dest))
    shutil.copyfile(src, dest)

CMAKE_UTILS = readFile(os.path.join(os.path.dirname(__file__), "scripts/CMakeUtils.cmake"))

parser = argparse.ArgumentParser(description="Kickstart new C++ project")
parser.add_argument("-d", "--directory", required=True, help="directory for the new project")

args = parser.parse_args()

properties = {
    "YEAR": datetime.datetime.now().year,
    "MAINTAINER": getpass.getuser(),
    "PROJECT": "MyProject"
}

def PATH(p):
    return os.path.join(args.directory, p)

try:
    initGit(args.directory)
except Exception as e:
    print e
    sys.exit()

try:
    runCommand("wget %s -O %s" % (GITIGNORE_URL, PATH(".gitignore")))
    appendToFile(PATH(".gitignore"), GITIGNORE_PATCH)
    writeToFile(PATH("LICENSE"), LICENSE.format(**properties))
    writeToFile(PATH("README.md"), README_MD.format(**properties))
    writeToFile(PATH("CMakeLists.txt"), ROOT_CMAKELISTS.format(**properties))
    writeToFile(PATH("build.sh"), BUILD_SH)
    runCommand("chmod a+x %s" % PATH("build.sh"))
    writeToFile(PATH("scripts/CMakeUtils.cmake"), CMAKE_UTILS)
    writeToFile(PATH("test/CMakeLists.txt"), TEST_CMAKELISTS.format(**properties))
    writeToFile(PATH("test/SampleTest.cpp"), TEST_CPP.format(**properties))
    runCommand("git -C %s add ." % args.directory)
except Exception as e:
    print e
    print "Reverting ..."
    shutil.rmtree(args.directory, ignore_errors=True)

print "Done"
