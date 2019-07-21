#!/usr/bin/python

import cmaketest
import unittest


class BuildStaticLibraryTest(cmaketest.TestCase):
    def testCreateStaticLib(self):
        result = self.runCMake("test/StaticLib")
        assert result.noErrors() or result.printErrors()
        assert "liba.a" in result.files()
        assert result.cmake.stdout.contains("Build Type: Debug")
        assert "-O0 -g -fprofile-arcs -ftest-coverage" in result.compile.commandOf("a.cpp")

    def testCreateShraedLibWithReleaseMode(self):
        result = self.runCMake("test/StaticLibWithReleaseMode")
        assert result.noErrors() or result.printErrors()
        assert "liba.a" in result.files()
        assert result.cmake.stdout.contains("Build Type: Release")
        assert "-O3 -DNDEBUG" in result.compile.commandOf("a.cpp")

    def testCreateStaticLibWithNamingOptions(self):
        result = self.runCMake("test/StaticLibWithNamingOptions")
        assert result.noErrors() or result.printErrors()
        assert "xxxa.library" in result.files()
        assert not "xxxa.library.1" in result.files()
        assert not "xxxa.library.1.2.3" in result.files()

    def testCreateStaticLibWithCustomAlias(self):
        result = self.runCMake("test/StaticLibWithCustomAlias")
        assert result.noErrors() or result.printErrors()
        assert "liba.a" in result.files()
        assert "main" in result.files()

    def testCreateStaticLibWithPrivateHeader(self):
        result = self.runCMake("test/StaticLibWithPrivateHeader")
        assert not result.noErrors() or result.printErrors()
        assert "liba.a" in result.files()
        assert not "main" in result.files()

    def testCreateStaticLibWithAnotherLib(self):
        result = self.runCMake("test/StaticLibWithAnotherLib")
        assert result.noErrors() or result.printErrors()
        assert "liba.a" in result.files()
        assert "libb.a" in result.files()

    def testCreateStaticLibWithCompileFlags(self):
        result = self.runCMake("test/StaticLibWithFlags")
        assert result.noErrors() or result.printErrors()
        assert "-DC -DCPP" in result.compile.commandOf("c.c")
        assert "-DCPP -DCXX" in result.compile.commandOf("cpp.cpp")
        assert "libc.a" in result.files()
        assert "libcpp.a" in result.files()


if __name__ == "__main__":
    unittest.main()
