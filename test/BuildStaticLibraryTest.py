#!/usr/bin/python

import cmaketest
import unittest


class BuildStaticLibraryTest(cmaketest.TestCase):
    phases = cmaketest.CMAKE | cmaketest.MAKE

    def testCreateStaticLib(self):
        result = self.runCMake("test/StaticLib", self.phases)
        assert result.stderr.empty()
        assert "liba.a" in result.files()
        assert result.stdout["cmake"].contains("Build Type: Debug")
        assert "-O0 -g -fprofile-arcs -ftest-coverage" in result.compile.commandOf("a.cpp")

    def testCreateShraedLibWithReleaseMode(self):
        result = self.runCMake("test/StaticLibWithReleaseMode", self.phases)
        assert result.stderr.empty()
        assert "liba.a" in result.files()
        assert result.stdout["cmake"].contains("Build Type: Release")
        assert "-O3 -DNDEBUG" in result.compile.commandOf("a.cpp")

    def testCreateStaticLibWithNamingOptions(self):
        result = self.runCMake("test/StaticLibWithNamingOptions", self.phases)
        assert result.stderr.empty()
        assert "xxxa.library" in result.files()
        assert not "xxxa.library.1" in result.files()
        assert not "xxxa.library.1.2.3" in result.files()

    def testCreateStaticLibWithCustomAlias(self):
        result = self.runCMake("test/StaticLibWithCustomAlias", self.phases)
        assert result.stderr.empty()
        assert "liba.a" in result.files()
        assert "main" in result.files()

    def testCreateStaticLibWithPrivateHeader(self):
        result = self.runCMake("test/StaticLibWithPrivateHeader")
        assert result.stderr["make"].contains("internal/a.hpp: No such file or directory")
        assert "liba.a" in result.files()
        assert not "main" in result.files()

    def testCreateStaticLibWithAnotherLib(self):
        result = self.runCMake("test/StaticLibWithAnotherLib", self.phases)
        assert result.stderr.empty()
        assert "liba.a" in result.files()
        assert "libb.a" in result.files()

    def testCreateStaticLibWithCompileFlags(self):
        result = self.runCMake("test/StaticLibWithFlags", self.phases)
        assert result.stderr.empty()
        assert "-DC -DCPP" in result.compile.commandOf("c.c")
        assert "-DCPP -DCXX" in result.compile.commandOf("cpp.cpp")
        assert "libc.a" in result.files()
        assert "libcpp.a" in result.files()


if __name__ == "__main__":
    unittest.main()
