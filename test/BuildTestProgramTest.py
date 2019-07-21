#!/usr/bin/python

import cmaketest
import unittest


class BuildTestProgramTest(cmaketest.TestCase):
    def testCreateTestProgram(self):
        result = self.runCMake("test/TestProgram")
        assert result.noErrors() or result.printErrors()
        assert "MyTest" in result.files()
        assert result.test.stdout.contains("1/1 Test #1: MyTest.test1")

    def testCreateTestProgramWithTwoTestCases(self):
        result = self.runCMake("test/TestProgramWithTwoTestCases")
        assert result.noErrors() or result.printErrors()
        assert "MyTest" in result.files()
        assert result.test.stdout.contains("1/2 Test #1: FirstTest.test1")
        assert result.test.stdout.contains("2/2 Test #2: SecondTest.test1")

    def testCreateTestProgramsWithTwoTests(self):
        result = self.runCMake("test/TestProgramWithTwoTests")
        assert result.noErrors() or result.printErrors()
        assert "FirstTest" in result.files()
        assert "SecondTest" in result.files()
        assert result.test.stdout.contains("1/2 Test #1: FirstTest.test1")
        assert result.test.stdout.contains("2/2 Test #2: SecondTest.test1")

if __name__ == "__main__":
    unittest.main()
