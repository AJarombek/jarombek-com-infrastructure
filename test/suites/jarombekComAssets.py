"""
Unit tests for the S3 bucket used for 'asset.jarombek.com'
Author: Andrew Jarombek
Date: 5/28/2019
"""

import unittest
import boto3


class TestJarombekComAssets(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.s3 = boto3.client('s3')