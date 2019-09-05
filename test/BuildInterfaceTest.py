#!/usr/bin/python

import cmaketest
import unittest


class BuildInterfaceTest(cmaketest.TestCase):
    def testBuildInterface(self):
        result = self.runCMake("test/Interface")
        assert result.stderr.emptyOf("cmake", "make")
        assert "/src/main" in result.files()


if __name__ == "__main__":
    unittest.main()
    
