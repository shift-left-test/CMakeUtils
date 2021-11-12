#!/usr/bin/python
#-*- coding: utf-8 -*-

"""
MIT License

Copyright (c) 2019 LG Electronics, Inc.

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

import argparse
import datetime
import getpass
import logging
import os
import shutil
import subprocess
import sys

logging.basicConfig(stream=sys.stdout,
                    format='%(levelname)-5s [%(lineno)3d]: %(message)s',
                    level=logging.INFO)

def execute(command):
    logging.info("Run: %s ..." % command)
    proc = subprocess.Popen(command, shell=True)
    return proc.communicate()

def initGit(path):
    logging.info("Create new directory at %s ..." % path)
    if os.path.exists(path):
        raise IOError("Directory already exists: %s" % path)
    os.makedirs(path)
    execute("git init %s" % path)

def writeFile(path, data):
    logging.info("Writing to %s ..." % path)
    if not os.path.exists(os.path.dirname(path)):
        os.makedirs(os.path.dirname(path))
    with open(path, "wb") as f:
        f.write(data)


def readFile(path):
    def readFrom(path):
        logging.info("Reading from %s ..." % path)
        with open(path, "rb") as f:
            return f.read()

    def resolve(path):
        root = os.path.dirname(__file__)
        return os.path.join(root, path)

    return readFrom(resolve(path))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Bootstrap for new C++ project",
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-d", "--directory", required=True, help="Directory to the new project")
    parser.add_argument("-m", "--maintainer", default=getpass.getuser(), help="Maintainer of the project")
    parser.add_argument("-p", "--project", default="MyProject", help="Project name")

    args = parser.parse_args()

    properties = {
        "YEAR" : datetime.datetime.now().year,
        "MAINTAINER": args.maintainer,
        "PROJECT": args.project,
    }

    def to(path):
        return os.path.join(args.directory, path)

    try:
        initGit(args.directory)
    except Exception as e:
        logging.error(e)
        sys.exit()

    try:
        writeFile(to("scripts/CMakeUtils.cmake"), readFile("scripts/CMakeUtils.cmake"))
        writeFile(to("scripts/FindGMock.cmake"), readFile("scripts/FindGMock.cmake"))
        templates = {}
        templates[".gitignore"] = readFile("resources/gitignore.template")
        templates["LICENSE"] = readFile("resources/license.template")
        templates["README.md"] = readFile("resources/readme.template")
        templates["CMakeLists.txt"] = readFile("resources/root_cmakelists.template")
        templates["build.sh"] = readFile("resources/build_sh.template")
        templates["CPPLINT.cfg"] = readFile("resources/cpplint.template")
        templates[".clang-tidy"] = readFile("resources/clang-tidy.template")
        templates["Doxyfile"] = readFile("resources/doxyfile.in.template")
        templates["include/echo/echo.hpp"] = readFile("resources/echo_hpp.template")
        templates["src/echo.cpp"] = readFile("resources/echo_cpp.template")
        templates["src/CMakeLists.txt"] = readFile("resources/src_cmakelists.template")
        templates["test/SampleTest.cpp"] = readFile("resources/sampletest_cpp.template")
        templates["test/CMakeLists.txt"] = readFile("resources/test_cmakelists.template")
        for path, template in templates.iteritems():
            writeFile(to(path), template.format(**properties))

        execute("chmod a+x %s" % to("build.sh"))
        execute("git -C %s add ." % to("."))

    except Exception as e:
        logging.error(e)
        logging.info("Reverting ...")
        shutil.rmtree(args.directory, ignore_errors=True)

    logging.info("Done")
