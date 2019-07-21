#!/usr/bin/python

import cmaketest
import unittest


class BuildProgramTest(cmaketest.TestCase):
    def testCreateProgram(self):
        result = self.runCMake("test/Program")
        assert result.noErrors() or result.printErrors()
        assert "main" in result.files()
        assert result.cmake.stdout.contains("Build Type: Debug")
        assert "-O0 -g -fprofile-arcs -ftest-coverage" in result.compile.commandOf("main.cpp")

    def testCreateProgramWithReleaseMode(self):
        result = self.runCMake("test/ProgramWithReleaseMode")
        assert result.noErrors() or result.printErrors()
        assert "main" in result.files()
        assert result.cmake.stdout.contains("Build Type: Release")
        assert "-O3 -DNDEBUG" in result.compile.commandOf("main.cpp")

    def testCreateProgramWithNamingOptions(self):
        result = self.runCMake("test/ProgramWithNamingOptions")
        assert  result.cmake.stderr.contains("Unsupported variable VERSION found")
        assert "xxxmain.exe" in result.files()

    def testCreateProgramWithCustomAlias(self):
        result = self.runCMake("test/ProgramWithCustomAlias")
        assert result.cmake.stderr.contains("Unsupported variable ALIAS found")
        assert "main" in result.files()

    def testCreateProgramWithPrivateHeader(self):
        result = self.runCMake("test/ProgramWithPrivateHeader")
        assert result.noErrors() or result.printErrors()
        assert "main" in result.files()

    def testCreateProgramWithPublicHeader(self):
        result = self.runCMake("test/ProgramWithPublicHeader")
        assert result.noErrors() or result.printErrors()
        assert "main" in result.files()

    def testCreateProgramWithAnotherProgram(self):
        result = self.runCMake("test/ProgramWithAnotherProgram")
        expected = 'Target "a" of type EXECUTABLE may not be linked into another target'
        assert result.cmake.stderr.contains(expected)
        assert not "a" in result.files()
        assert not "b" in result.files()

    def testCreateProgramWithCompileFlags(self):
        result = self.runCMake("test/ProgramWithFlags")
        assert result.noErrors() or result.printErrors()
        assert "-DC -DCPP" in result.compile.commandOf("c.c")
        assert "-DCPP -DCXX" in result.compile.commandOf("cpp.cpp")
        assert "main" in result.files()


if __name__ == "__main__":
    unittest.main()
