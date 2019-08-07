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


if __name__ == "__main__":
    unittest.main()
