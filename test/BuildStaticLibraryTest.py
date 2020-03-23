#!/usr/bin/python

import cmaketest
import unittest


class BuildStaticLibraryTest(cmaketest.TestCase):
    def testCreateStaticLib(self):
        result = self.runCMake("test/StaticLib")
        assert result.stderr.emptyOf("cmake", "make")
        assert "liba.a" in result.files()
        assert result.stdout["cmake"].contains("Build Type: Debug")
        assert "-g -fprofile-arcs -ftest-coverage" in result.compile.commandOf("a.cpp")

    def testCreateShraedLibWithReleaseMode(self):
        result = self.runCMake("test/StaticLibWithReleaseMode")
        assert result.stderr.emptyOf("cmake", "make")
        assert "liba.a" in result.files()
        assert "-O3 -DNDEBUG" in result.compile.commandOf("a.cpp")

    def testCreateStaticLibWithNamingOptions(self):
        result = self.runCMake("test/StaticLibWithNamingOptions")
        assert result.stderr.emptyOf("cmake", "make")
        assert "xxxa.library" in result.files()
        assert not "xxxa.library.1" in result.files()
        assert not "xxxa.library.1.2.3" in result.files()

    def testCreateStaticLibWithCustomAlias(self):
        result = self.runCMake("test/StaticLibWithCustomAlias")
        assert result.stderr.emptyOf("cmake", "make")
        assert "liba.a" in result.files()
        assert "main" in result.files()

    def testCreateStaticLibWithPrivateHeader(self):
        result = self.runCMake("test/StaticLibWithPrivateHeader")
        assert result.stderr["make"].contains("fatal error: internal/a.hpp")
        assert "liba.a" in result.files()
        assert not "main" in result.files()

    def testCreateStaticLibWithAnotherLib(self):
        result = self.runCMake("test/StaticLibWithAnotherLib")
        assert result.stderr.emptyOf("cmake", "make")
        assert "liba.a" in result.files()
        assert "libb.a" in result.files()

    def testCreateStaticLibWithCompileFlags(self):
        result = self.runCMake("test/StaticLibWithFlags")
        assert result.stderr.emptyOf("cmake", "make")
        assert "-DC -DCPP" in result.compile.commandOf("c.c")
        assert "-DCPP -DCXX" in result.compile.commandOf("cpp.cpp")
        assert "libc.a" in result.files()
        assert "libcpp.a" in result.files()


if __name__ == "__main__":
    unittest.main()
