#!/usr/bin/python

import cmaketest
import unittest


class BuildSharedLibraryTest(cmaketest.TestCase):
    def testCreateSharedLib(self):
        result = self.runCMake("test/SharedLib")
        assert result.stderr.emptyOf("cmake", "make")
        assert "liba.so" in result.files()
        assert result.stdout["cmake"].contains("Build Type: Debug")
        assert "-O0 -g -fprofile-arcs -ftest-coverage" in result.compile.commandOf("a.cpp")

    def testCreateShraedLibWithReleaseMode(self):
        result = self.runCMake("test/SharedLibWithReleaseMode")
        assert result.stderr.emptyOf("cmake", "make")
        assert "liba.so" in result.files()
        assert result.stdout["cmake"].contains("Build Type: Release")
        assert "-O3 -DNDEBUG" in result.compile.commandOf("a.cpp")

    def testCreateSharedLibWithNamingOptions(self):
        result = self.runCMake("test/SharedLibWithNamingOptions")
        assert result.stderr.emptyOf("cmake", "make")
        assert "xxxa.library.1" in result.files()
        assert "xxxa.library.1.2.3" in result.files()

    def testCreateSharedLibWithCustomAlias(self):
        result = self.runCMake("test/SharedLibWithCustomAlias")
        assert result.stderr.emptyOf("cmake", "make")
        assert "liba.so" in result.files()
        assert "main" in result.files()

    def testCreateSharedLibWithPrivateHeader(self):
        result = self.runCMake("test/SharedLibWithPrivateHeader")
        assert result.stderr["make"].contains("internal/a.hpp: No such file or directory")
        assert "liba.so" in result.files()
        assert not "main" in result.files()

    def testCreateSharedLibWithAnotherLib(self):
        result = self.runCMake("test/SharedLibWithAnotherLib")
        assert result.stderr.emptyOf("cmake", "make")
        assert "liba.so" in result.files()
        assert "libb.so" in result.files()

    def testCreateSharedLibWithCompileFlags(self):
        result = self.runCMake("test/SharedLibWithFlags")
        assert result.stderr.emptyOf("cmake", "make")
        assert "-DC -DCPP" in result.compile.commandOf("c.c")
        assert "-DCPP -DCXX" in result.compile.commandOf("cpp.cpp")
        assert "libc.so" in result.files()
        assert "libcpp.so" in result.files()


if __name__ == "__main__":
    unittest.main()
