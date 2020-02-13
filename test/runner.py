"""
Runner which executes the test suite for my jarombek.com AWS infrastructure
Author: Andrew Jarombek
Date: 5/27/2019
"""

import unittest
import test.suites.acm as acm
import test.suites.iam as iam
import test.suites.route53 as route53
import test.suites.jarombekCom as jarombekCom
import test.suites.jarombekComAssets as jarombekComAssets
import test.suites.jarombekComReact163 as jarombekComReact163

# Create the test suite
loader = unittest.TestLoader()
suite = unittest.TestSuite()

# Add test files to the test suite
suite.addTests(loader.loadTestsFromModule(acm))
suite.addTests(loader.loadTestsFromModule(iam))
suite.addTests(loader.loadTestsFromModule(route53))
suite.addTests(loader.loadTestsFromModule(jarombekCom))
suite.addTests(loader.loadTestsFromModule(jarombekComAssets))
suite.addTests(loader.loadTestsFromModule(jarombekComReact163))

# Create a test runner an execute the test suite
runner = unittest.TextTestRunner(verbosity=3)
result = runner.run(suite)
