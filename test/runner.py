"""
Runner which executes the test suite for my jarombek.com AWS infrastructure
Author: Andrew Jarombek
Date: 5/27/2019
"""

import unittest
import suites.acm as acm

# Create the test suite
loader = unittest.TestLoader()
suite = unittest.TestSuite()

# Add test files to the test suite
suite.addTests(loader.loadTestsFromModule(acm))

# Create a test runner an execute the test suite
runner = unittest.TextTestRunner(verbosity=3)
result = runner.run(suite)
