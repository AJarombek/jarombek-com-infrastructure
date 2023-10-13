"""
Unit tests for the ACM HTTPS certificates and corresponding Route53 infrastructure
Author: Andrew Jarombek
Date: 5/27/2019
"""

import unittest
import os

import boto3

try:
    prod_env = os.environ["TEST_ENV"] == "prod"
except KeyError:
    prod_env = True


class TestACM(unittest.TestCase):
    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.acm = boto3.client("acm")
        self.acm_certificates = self.acm.list_certificates(
            CertificateStatuses=["ISSUED"]
        )

    @unittest.skipIf(prod_env, "Dev wildcard certificate not needed for production.")
    @unittest.skipIf(not prod_env, "Dev website not currently running.")
    def test_dev_wildcard_cert_issued(self) -> None:
        """
        Test that the dev wildcard ACM certificate exists
        """
        for cert in self.acm_certificates.get("CertificateSummaryList"):
            if cert.get("DomainName") == "*.dev.jarombek.com":
                self.assertTrue(True)
                return

        self.assertFalse(True)

    def test_wildcard_cert_issued(self) -> None:
        """
        Test that the wildcard ACM certificate exists
        """
        for cert in self.acm_certificates.get("CertificateSummaryList"):
            if cert.get("DomainName") == "*.jarombek.com":
                self.assertTrue(True)
                return

        self.assertFalse(True)
