"""
Unit tests for the S3 bucket used for 'react16-3.demo.jarombek.com'
Author: Andrew Jarombek
Date: 2/2/2020
"""

import unittest
import boto3
import urllib.request as request


class TestJarombekComReact163(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.s3 = boto3.client('s3')

    def test_react16_3_demo_jarombek_com_bucket_exists(self) -> None:
        """
        Test if an S3 bucket for react16-3.demo.jarombek.com exists
        """
        s3_bucket = self.s3.list_objects(Bucket='react16-3.demo.jarombek.com')
        self.assertEqual(s3_bucket.get('Name'), 'react16-3.demo.jarombek.com')

    def test_react16_3_demo_jarombek_com_bucket_not_empty(self) -> None:
        """
        Test if the S3 bucket for react16-3.demo.jarombek.com contains objects
        """
        contents = self.s3.list_objects(Bucket='react16-3.demo.jarombek.com').get('Contents')
        self.assertGreater(len(contents), 0)

    def test_react16_3_demo_jarombek_com_reachable(self) -> None:
        """
        Test that the react16-3.demo.jarombek.com S3 bucket is reachable via HTTPS
        """
        req = request.Request(url='https://react16-3.demo.jarombek.com')
        with request.urlopen(req) as f:
            self.assertEqual(f.status, 200)

    def test_react16_3_demo_jarombek_com_invalid_endpoint_reachable(self) -> None:
        """
        Test that an endpoint that would return a 404 is redirected to a valid endpoint that returns a 200 in the
        react16-3.demo.jarombek.com S3 bucket.
        """
        req = request.Request(url='https://react16-3.demo.jarombek.com')
        with request.urlopen(req) as f:
            self.assertEqual(f.status, 200)

    def test_www_react16_3_demo_jarombek_com_reachable(self) -> None:
        """
        Test that the www.react16-3.demo.jarombek.com S3 bucket is reachable via HTTPS
        """
        req = request.Request(url='https://www.react16-3.demo.jarombek.com')
        with request.urlopen(req) as f:
            self.assertEqual(f.status, 200)

    def test_www_react16_3_demo_jarombek_com_invalid_endpoint_reachable(self) -> None:
        """
        Test that an endpoint that would return a 404 is redirected to a valid endpoint that returns a 200 in the
        www.react16-3.demo.jarombek.com S3 bucket.
        """
        req = request.Request(url='https://www.react16-3.demo.jarombek.com')
        with request.urlopen(req) as f:
            self.assertEqual(f.status, 200)
