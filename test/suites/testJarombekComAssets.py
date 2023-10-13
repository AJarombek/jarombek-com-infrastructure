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
        self.s3 = boto3.client("s3")
        self.bucket_name = "asset.jarombek.com"

    def test_assets_jarombek_com_bucket_exists(self) -> None:
        """
        Test if an S3 bucket for asset.jarombek.com exists
        """
        s3_bucket = self.s3.list_objects(Bucket=self.bucket_name)
        self.assertEqual(s3_bucket.get("Name"), self.bucket_name)

    def test_s3_bucket_public_access(self) -> None:
        """
        Test whether the public access configuration for a asset.jarombek.com S3 bucket is correct
        """
        public_access_block = self.s3.get_public_access_block(Bucket=self.bucket_name)
        config = public_access_block.get("PublicAccessBlockConfiguration")
        self.assertTrue(config.get("BlockPublicAcls"))
        self.assertTrue(config.get("IgnorePublicAcls"))
        self.assertTrue(config.get("BlockPublicPolicy"))
        self.assertTrue(config.get("RestrictPublicBuckets"))

    def test_assets_jarombek_com_bucket_not_empty(self) -> None:
        """
        Test if the S3 bucket for asset.jarombek.com contains objects
        """
        contents = self.s3.list_objects(Bucket=self.bucket_name).get("Contents")
        self.assertGreater(len(contents), 0)

    def test_assets_jarombek_com_reachable(self) -> None:
        """
        Test that the asset.jarombek.com S3 bucket is reachable via HTTPS
        Source: https://docs.python.org/3/library/urllib.request.html#examples
        """
        req = request.Request(url="https://asset.jarombek.com")
        with request.urlopen(req) as f:
            self.assertEqual(f.status, 200)

    def test_www_assets_jarombek_com_reachable(self) -> None:
        """
        Test that the www.asset.jarombek.com S3 bucket is reachable via HTTPS
        Source: https://docs.python.org/3/library/urllib.request.html#examples
        """
        req = request.Request(url="https://www.asset.jarombek.com")
        with request.urlopen(req) as f:
            self.assertEqual(f.status, 200)
