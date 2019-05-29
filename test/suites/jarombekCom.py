"""
Unit tests for the S3 bucket used for the jarombek.com ECS cluster
Author: Andrew Jarombek
Date: 5/28/2019
"""

import unittest
import boto3
import os
from utils.Route53 import Route53


class TestJarombekCom(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ec2 = boto3.client('ec2')
        self.route53 = boto3.client('route53')

        try:
            prod_env = os.environ['TEST_ENV'] == "prod"
        except KeyError:
            prod_env = True

        if prod_env:
            self.website_url = "jarombek.com"
        else:
            self.website_url = "dev.jarombek.com"

    def test_jarombek_com_a_record_exists(self) -> None:
        """
        Determine if the 'A' record exists for the website in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.com.', self.website_url, 'A')
        except IndexError:
            self.assertFalse(True)

        self.assertEqual(a_record.get('Name'), self.website_url)
        self.assertEqual(a_record.get('Type'), 'A')

    def test_www_jarombek_com_a_record_exists(self) -> None:
        """
        Determine if the 'A' record exists for the 'www' prefixed website in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.com.', f'www.${self.website_url}', 'A')
        except IndexError:
            self.assertFalse(True)

        self.assertEqual(a_record.get('Name'), f'www.${self.website_url}')
        self.assertEqual(a_record.get('Type'), 'A')