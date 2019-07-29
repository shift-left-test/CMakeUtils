from __future__ import print_function
import os
import subprocess
import tempfile
import shutil
import unittest
import json

# Enumeration of cmake phases
CMAKE = 1
MAKE = 2
CHECK = 4
TEST = 8


class Output(object):
    """The console output holder class.

    This class provides various output comparison helper functions.
    """

    def __init__(self, output):
        """Default constructor

        Args:
          output (str): a console output string
        """
        self.output = output

    def empty(self):
        """Assert that the output is empty

        Returns:
          True if the output is empty, False otherwise
        """
        return not self.output.strip()

    def contains(self, keyword):
        """Assert that the output contains the given keyword

        Args:
         keyword (str): text to examine

        Returns:
          True if the output contains the text, False otherwise
        """
        return keyword in self.output

    def containsAll(self, *keywords):
        for keyword in keywords:
            if not self.contains(keyword):
                return False
        return True

    def containsAny(self, *keywords):
        for keyword in keywords:
            if keyword in self.output:
                return True
        return False

    def __str__(self):
        """Print the console output string
        """
        return self.output

class Outputs(object):
    def __init__(self):
        self.outputs = {}

    def __getitem__(self, key):
        return self.outputs[key]

    def __setitem__(self, key, value):
        self.outputs[key] = value

    def empty(self):
        return all(output.empty() for output in self.outputs.values())

    def emptyOf(self, *keys):
        filtered = []
        for key, value in self.outputs.items():
            if key in keys:
                filtered.append(value)
        return all(output.empty() for output in filtered)

    def __str__(self):
        items = self.outputs.items()
        return ", ".join("'{0}'='{1}'".format(key, value) for (key, value) in items)

class Phase(object):
    """The phase class to distinguish between the configuration stage (cmake)
    and the actual build stage (make).

    This class holds the stdout and stderr of the each stage.
    """

    def __init__(self, outputs):
        """Default constructor

        Args:
          outputs (tuple): stderr and stdout
        """
        self.stdout = Output(outputs[0])
        self.stderr = Output(outputs[1])

class CompileCommands(object):
    """This class holds the information of compilation commands
    """
    def __init__(self, tempDir):
        self.tempDir = tempDir

    def commandOf(self, filename):
        """Return the relevant compile command of the given file
        """
        commands = {}
        try:
            f = os.path.join(self.tempDir, "compile_commands.json")
            commands = json.load(open(f, "r"))
        except:
            return ""

        for command in commands:
            if command["file"].endswith(filename):
                return command["command"]
        return ""

class BuildResult(object):
    """This class contains the overall build result of the cmake and provides
    various helper functions to examine the build result generated by a given
    cmake script.
    """

    def __init__(self, tempDir):
        """Default constructor

        Args:
          tempDir (file): path to a temporary directory
        """
        self.tempDir = tempDir
        self.stdout = Outputs()
        self.stderr = Outputs()
        self.compile = CompileCommands(tempDir)

    def append(self, key, value):
        self.stdout[key] = value.stdout
        self.stderr[key] = value.stderr

    def files(self):
        """List of the files within the build directory
        """
        fileSet = []
        for root, _, files in os.walk(self.tempDir):
            for f in files:
                fileSet.append(os.path.join(root[len(self.tempDir):], f))
        return fileSet

    def resolve(self, path):
        """Resolve a relative path against the build directory
        """
        return os.path.join(self.tempDir, path)

    def exists(self, filename):
        """Test if the given file exists in the build directory
        """
        return os.path.exists(self.resolve(filename))


class CMakeTestUtil(object):
    """A CMake helper class for testing purpose
    """
    def __init__(self):
        """Default constructor
        """
        self.tempDirs = []

    def __del__(self):
        """Default destructor

        This is intended to delete the temporal build directories
        """
        for tempDir in self.tempDirs:
            try:
                if os.path.exists(tempDir):
                    shutil.rmtree(tempDir)
            except OSError as e:
                print(e)

    def runCMake(self, sourceDir, phases):
        """Execute a CMakeLists.txt under the given source directory and
        return the result as an instance of BuildResult

        Args:
          sourceDir (str): path to a directory which contains a CMakeLists.txt
          phases (enum): set of cmake commands to trigger

        Returns:
          BuildResult instance
        """
        def execute(command):
            proc = subprocess.Popen(command, shell = True,
                                    stdout = subprocess.PIPE,
                                    stderr = subprocess.PIPE)
            return Phase(proc.communicate())

        tempDir = tempfile.mkdtemp(suffix=".test", prefix="cmake_")
        self.tempDirs.append(tempDir)

        cmakeDir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "scripts")

        result = BuildResult(tempDir)

        if (phases & CMAKE):
            result.append("cmake", execute("cmake -H{0} -B{1} -DCMAKE_MODULE_PATH={2}".format(sourceDir, tempDir, cmakeDir)))
        if (phases & MAKE):
            result.append("make", execute("make -C {0}".format(tempDir)))
        if (phases & CHECK):
            result.append("check", execute("make check -C {0}".format(tempDir)))
        if (phases & TEST):
            result.append("test", execute("make test -C {0}".format(tempDir)))

        return result


class TestCase(unittest.TestCase):
    """CMake test helper class

    This class works as a foundation of the CMake test cases.
    """
    def setUp(self):
        self.util = CMakeTestUtil()

    def tearDown(self):
        del self.util

    def runCMake(self, sourceDir, phases = CMAKE | MAKE | CHECK | TEST):
        return self.util.runCMake(sourceDir, phases)
