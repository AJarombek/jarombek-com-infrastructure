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
        self.elb = boto3.client('elbv2')

        try:
            prod_env = os.environ['TEST_ENV'] == "prod"
        except KeyError:
            prod_env = True

        if prod_env:
            self.env = "prod"
            self.website_url = "jarombek.com"
        else:
            self.env = "dev"
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

    def test_www_jarombek_com_cname_record_exists(self) -> None:
        """
        Determine if the 'CNAME' record exists for the 'www' prefixed website in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.com.', f'www.${self.website_url}', 'CNAME')
        except IndexError:
            self.assertFalse(True)

        self.assertEqual(a_record.get('Name'), f'www.${self.website_url}')
        self.assertEqual(a_record.get('Type'), 'CNAME')

    def test_load_balancer_active(self) -> None:
        """
        Prove that an application load balancer is running and has proper configuration
        """
        response = self.elb.describe_load_balancers(
            Names=[f'jarombek-com-{self.env}-alb']
        )

        load_balancers = response.get('LoadBalancers')
        self.assertEqual(len(load_balancers), 1)

        alb = load_balancers[0]
        self.assertEqual(alb.get('Scheme'), 'internet-facing')
        self.assertEqual(alb.get('State').get('Code'), 'active')
        self.assertEqual(alb.get('Type'), 'application')

    def test_listener_http(self) -> None:
        """
        Prove that the listener for HTTP requests is configured properly
        """
        response = self.elb.describe_load_balancers(
            Names=[f'jarombek-com-{self.env}-alb']
        )
        load_balancer = response.get('LoadBalancers')[0]

        response = self.elb.describe_listeners(
            LoadBalancerArn=load_balancer.get('LoadBalancerArn')
        )

        listeners = response.get('Listeners')
        self.assertEqual(len(listeners), 2)

    def test_listener_https(self) -> None:
        """
        Prove that the listener for HTTPS requests is configured properly
        """
        pass

    def test_target_group_http(self) -> None:
        """
        Prove that the target group for the load balancer is configured properly
        """
        response = self.elb.describe_target_groups(
            Names=[f'jarombek-com-{self.env}-lb-target']
        )
