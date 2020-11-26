"""
Unit tests for Route53 records and zones for the jarombek.com infrastructure
Author: Andrew Jarombek
Date: 5/28/2019
"""

import unittest
import boto3

from aws_test_functions.Route53 import Route53


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

    def test_jarombek_com_ns_record_exists(self) -> None:
        """
        Determine if the 'NS' record exists for 'jarombek.com.' in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.com.', 'jarombek.com.', 'NS')
        except IndexError:
            a_record = None
            self.assertFalse(True)

        self.assertEqual(a_record.get('Name'), 'jarombek.com.')
        self.assertEqual(a_record.get('Type'), 'NS')

    def test_jarombek_com_a_record_exists(self) -> None:
        """
        Determine if the 'A' record exists for 'jarombek.com.' in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.com.', 'asset.jarombek.com.', 'A')
        except IndexError:
            a_record = None
            self.assertFalse(True)

        self.assertEqual(a_record.get('Name'), 'asset.jarombek.com.')
        self.assertEqual(a_record.get('Type'), 'A')

    def test_www_jarombek_com_a_record_exists(self) -> None:
        """
        Determine if the 'A' record exists for 'www.jarombek.com.' in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.com.', 'www.asset.jarombek.com.', 'A')
        except IndexError:
            a_record = None
            self.assertFalse(True)

        self.assertEqual(a_record.get('Name'), 'www.asset.jarombek.com.')
        self.assertEqual(a_record.get('Type'), 'A')

    def test_jarombek_com_mx_record_exists(self) -> None:
        """
        Determine if the 'MX' record exists for 'jarombek.com.' in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.com.', 'jarombek.com.', 'MX')
        except IndexError:
            a_record = None
            self.assertFalse(True)

        self.assertEqual(a_record.get('Name'), 'jarombek.com.')
        self.assertEqual(a_record.get('Type'), 'MX')
