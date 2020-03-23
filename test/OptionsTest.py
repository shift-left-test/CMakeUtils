#!/usr/bin/python

import cmaketest
import unittest


class OptionsTest(cmaketest.TestCase):
    def testSetCStandard(self):
        result = self.runCMake("test/set_c_standard")
        assert result.stderr.emptyOf("cmake", "make")
        assert "main" in result.files()
        assert "-std=c99" in result.compile.commandOf("main.c")

    def testSetCXXStandard(self):
        result = self.runCMake("test/set_cxx_standard")
        assert result.stderr.emptyOf("cmake", "make")
        assert "main" in result.files()
        assert "-std=c++11" in result.compile.commandOf("main.cpp")

    def testSetDefaultBuildType(self):
        result = self.runCMake("test/set_default_build_type")
        assert result.stderr.emptyOf("cmake", "make")
        assert result.stdout["cmake"].contains("Build Type: DebugWithRelInfo")

    def testAddAllSubDirectories(self):
        result = self.runCMake("test/add_all_subdirectories")
        assert result.stderr.emptyOf("cmake", "make")
        assert "/2/2/2/main" in result.files()

    def testEnableTestCoverage(self):
        result = self.runCMake("test/enable_test_coverage")
        assert result.stderr.emptyOf("cmake", "make", "test", "coverage")
        assert result.stdout["coverage"].contains("Branches")

    def testEnableDoxygen(self):
        result = self.runCMake("test/enable_doxygen")
        assert result.stderr.emptyOf("cmake", "doc")
        assert "/html/main_8cpp.html" in result.files()

    def testCompileOptions(self):
        result = self.runCMake("test/compile_options")
        assert result.stderr.emptyOf("cmake", "make")
        assert "-Wall" in result.compile.commandOf("main.cpp")
        assert "-Wall" in result.compile.commandOf("plus.cpp")

    def testLinkOptions(self):
        result = self.runCMake("test/link_options")
        assert result.stderr.emptyOf("cmake", "make")
        assert result.stdout["make"].contains("-L/test-path")

    def testCrossCompilingEmulatorOptions(self):
        result = self.runCMake("test/CrossCompilingEmulatorOption")
        assert result.stdout["cmake"].contains("Found cross-compiling emulator: TRUE")
        assert result.stderr.emptyOf("cmake", "make")
        assert result.stderr["test"].contains("Unable to find executable: qemu-unknown")


if __name__ == "__main__":
    unittest.main()
