#!/bin/bash

py.test -vv -x -s --junitxml result.xml test/*Test.py
