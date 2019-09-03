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

    def testAddAllSubDirectories(self):
        result = self.runCMake("test/add_all_subdirectories")
        assert result.stderr.emptyOf("cmake", "make")
        assert "/2/2/2/main" in result.files()


if __name__ == "__main__":
    unittest.main()
