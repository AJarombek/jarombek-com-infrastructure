"""
Unit tests for Route53 records and zones for the jarombek.com infrastructure
Author: Andrew Jarombek
Date: 5/28/2019
"""

import unittest
import boto3
import utils.Route53 as Route53


class TestRoute53(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.route53 = boto3.client('route53')

    def test_jarombek_com_zone_exists(self) -> None:
        """
        Determine if the jarombek.com Route53 zone exists.
        """
        zones = self.route53.list_hosted_zones_by_name(DNSName='jarombek.com.', MaxItems='1').get('HostedZones')
        self.assertEqual(len(zones), 1)

    def test_jarombek_com_zone_public(self) -> None:
        """
        Determine if the jarombek.com Route53 zone is public.
        """
        zones = self.route53.list_hosted_zones_by_name(DNSName='jarombek.com.', MaxItems='1').get('HostedZones')
        self.assertFalse(zones[0].get('Config').get('PrivateZone'))
