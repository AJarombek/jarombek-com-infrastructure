"""
Unit tests for the S3 bucket used for 'asset.jarombek.com'
Author: Andrew Jarombek
Date: 5/28/2019
"""

import unittest
import boto3
import urllib.request as request


class TestJarombekComAssets(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.s3 = boto3.client('s3')

    def test_assets_jarombek_com_bucket_exists(self) -> None:
        """
        Test if an S3 bucket for asset.jarombek.com exists
        """
        s3_bucket = self.s3.list_objects(Bucket='asset.jarombek.com')
        self.assertEqual(s3_bucket.get('Name'), 'asset.jarombek.com')

    def test_assets_jarombek_com_bucket_not_empty(self) -> None:
        """
        Test if the S3 bucket for asset.jarombek.com contains objects
        """
        contents = self.s3.list_objects(Bucket='asset.jarombek.com').get('Contents')
        self.assertGreater(len(contents), 0)

    def test_assets_jarombek_com_reachable(self) -> None:
        """
        Test that the asset.jarombek.com S3 bucket is reachable via HTTPS
        Source: https://docs.python.org/3/library/urllib.request.html#examples
        """
        req = request.Request(url='https://asset.jarombek.com')
        with request.urlopen(req) as f:
            self.assertEqual(f.status, 200)

    def test_www_assets_jarombek_com_bucket_exists(self) -> None:
        """
        Test if an S3 bucket for www.asset.jarombek.com exists
        """
        s3_bucket = self.s3.list_objects(Bucket='www.asset.jarombek.com')
        self.assertEqual(s3_bucket.get('Name'), 'www.asset.jarombek.com')

    def test_www_assets_jarombek_com_bucket_empty(self) -> None:
        """
        Test if the S3 bucket for www.asset.jarombek.com contains objects
        """
        contents = self.s3.list_objects(Bucket='www.asset.jarombek.com').get('Contents')
        self.assertIsNone(contents)

    def test_www_assets_jarombek_com_reachable(self) -> None:
        """
        Test that the www.asset.jarombek.com S3 bucket is reachable via HTTPS
        Source: https://docs.python.org/3/library/urllib.request.html#examples
        """
        req = request.Request(url='https://www.asset.jarombek.com')
        with request.urlopen(req) as f:
            self.assertEqual(f.status, 200)
