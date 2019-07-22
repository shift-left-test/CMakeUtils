#!/usr/bin/python

import cmaketest
import unittest


class BuildTestProgramTest(cmaketest.TestCase):
    def testCreateTestProgram(self):
        result = self.runCMake("test/TestProgram")
        assert result.stderr.empty()
        assert "MyTest" in result.files()
        assert result.stdout["test"].contains("1/1 Test #1: MyTest.test1")

    def testCreateTestProgramWithTwoTestCases(self):
        result = self.runCMake("test/TestProgramWithTwoTestCases")
        assert result.stderr.empty()
        assert "MyTest" in result.files()
        assert result.stdout["test"].contains("1/2 Test #1: FirstTest.test1")
        assert result.stdout["test"].contains("2/2 Test #2: SecondTest.test1")

    def testCreateTestProgramsWithTwoTests(self):
        result = self.runCMake("test/TestProgramWithTwoTests")
        assert result.stderr.empty()
        assert "FirstTest" in result.files()
        assert "SecondTest" in result.files()
        assert result.stdout["test"].contains("1/2 Test #1: FirstTest.test1")
        assert result.stdout["test"].contains("2/2 Test #2: SecondTest.test1")

if __name__ == "__main__":
    unittest.main()
