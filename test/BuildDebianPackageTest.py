#!/usr/bin/python

import cmaketest
import unittest


class BuildDebianPackageTest(cmaketest.TestCase):
    def testCreatePackageWithProgram(self):
        result = self.runCMake("test/PackageProgram")
        assert result.stderr.emptyOf("package")
        assert result.exists("test-0.0.1-amd64.deb")
        assert result.exists("_CPack_Packages/Linux/DEB/test-0.0.1-amd64/usr/bin/main.out")

    def testCreatePackageLibWithPrivateHeader(self):
        result = self.runCMake("test/PackageLibWithPrivateHeader")
        assert result.stderr.emptyOf("package")
        assert result.exists("test-1.0.0-amd64.deb")
        assert result.exists("_CPack_Packages/Linux/DEB/test-1.0.0-amd64/usr/lib/liba.so")
        assert not result.exists("_CPack_Packages/Linux/DEB/test-1.0.0-amd64/usr/include/a.hpp")

    def testCreatePackageDoesNotIncludeTestProgram(self):
        result = self.runCMake("test/PackageTestProgram")
        assert result.stderr.emptyOf("package")
        assert result.exists("test-1.0.0-amd64.deb")
        assert result.exists("_CPack_Packages/Linux/DEB/test-1.0.0-amd64/usr/lib/libmodule.a")
        assert result.exists("test/unittest.out")
        assert not result.exists("_CPack_Packages/Linux/DEB/test-1.0.0-amd64/usr/bin/unittest")

if __name__ == "__main__":
    unittest.main()
