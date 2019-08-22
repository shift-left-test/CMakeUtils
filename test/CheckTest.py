#!/usr/bin/python

import cmaketest
import unittest

class CheckTest(cmaketest.TestCase):
    checkers = ["clang-tidy", "cpplint", "cppcheck"]

    def testCheckWithInitState(self):
        result = self.runCMake("test/checkWithInitState")
        assert not result.stdout["cmake"].containsAll(*self.checkers)
        assert result.stderr.emptyOf("cmake", "make", "check")

    def testCheckWithAllAgainstValidCode(self):
        result = self.runCMake("test/checkWithAllAgainstValidCode")
        assert result.stdout["cmake"].containsAll(*self.checkers)
        assert result.stdout["check"].containsAll("Running clang-tidy...",
                                                  "Running cppcheck...",
                                                  "Running cpplint...")

    def testCheckWithCpplintAgainstMalformedCode(self):
        result = self.runCMake("test/checkWithCpplint")
        assert result.stdout["cmake"].contains("cpplint")
        assert not result.stdout["cmake"].containsAll(*self.checkers)
        assert result.stderr["check"].containsAll("b.hpp:0:  No copyright message found.",
                                                  "b.hpp:7:  At least two spaces is best between code and comments",
                                                  "main.cpp:11:  Redundant blank line")

    def testCheckWithClangTidyAgainstMalformedCode(self):
        result = self.runCMake("test/checkWithClangTidy")
        assert result.stdout["cmake"].contains("clang-tidy")
        assert not result.stdout["cmake"].containsAll(*self.checkers)
        assert result.stdout["check"].containsAll("Number.hpp:3:3: warning: single-argument constructors must be marked explicit")

    def testCheckWithCppcheckAgainstMalformedCode(self):
        result = self.runCMake("test/checkWithCppcheck")
        assert result.stdout["cmake"].contains("cppcheck")
        assert not result.stdout["cmake"].containsAll(*self.checkers)
        assert result.stderr["check"].containsAll("divide.cpp:5]: (style) The function 'divide' is never used",
                                                  "minus.cpp:5]: (style) The function 'minus' is never used")

if __name__ == "__main__":
    unittest.main()
