"""
Unit tests for the S3 bucket used for the jarombek.com ECS cluster
Author: Andrew Jarombek
Date: 5/28/2019
"""

import unittest
import boto3


class TestJarombekCom(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ec2 = boto3.client('ec2')