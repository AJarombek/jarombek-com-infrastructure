"""
Unit tests for the S3 bucket used for the jarombek.com ECS cluster
Author: Andrew Jarombek
Date: 5/28/2019
"""

import unittest
import boto3
import os
from utils.Route53 import Route53
from utils.LoadBalancing import LB


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
        load_balancers = LB.get_load_balancers(name=f'jarombek-com-{self.env}-alb')
        self.assertEqual(len(load_balancers), 1)

        alb = load_balancers[0]
        self.assertEqual(alb.get('Scheme'), 'internet-facing')
        self.assertEqual(alb.get('State').get('Code'), 'active')
        self.assertEqual(alb.get('Type'), 'application')

    def test_listener_http(self) -> None:
        """
        Prove that the listener for HTTP requests is configured properly
        """
        listeners = LB.get_listeners(lb_name=f'jarombek-com-{self.env}-alb')
        self.assertEqual(len(listeners), 2)

        http_listeners = [item for item in listeners if item.get('Protocol') == 'HTTP']
        self.assertEqual(len(http_listeners), 1)

        http_listener = http_listeners[0]
        self.assertEqual(http_listener.get('Protocol'), 'HTTP')
        self.assertEqual(http_listener.get('Port'), 80)

        default_actions = http_listener.get('DefaultActions')
        self.assertEqual(len(default_actions), 1)

        default_action = default_actions[0]
        self.assertEqual(default_action.get('Type'), 'redirect')
        self.assertEqual(default_action.get('RedirectConfig').get('Protocol'), 'HTTPS')
        self.assertEqual(default_action.get('RedirectConfig').get('Port'), 443)
        self.assertEqual(default_action.get('RedirectConfig').get('StatusCode'), 'HTTP_301')

    def test_listener_https(self) -> None:
        """
        Prove that the listener for HTTPS requests is configured properly
        """
        listeners = LB.get_listeners(lb_name=f'jarombek-com-{self.env}-alb')
        self.assertEqual(len(listeners), 2)

        https_listeners = [item for item in listeners if item.get('Protocol') == 'HTTPS']
        self.assertEqual(len(https_listeners), 1)

        https_listener = https_listeners[0]
        self.assertEqual(https_listener.get('Protocol'), 'HTTPS')
        self.assertEqual(https_listener.get('Port'), 443)

        default_actions = https_listener.get('DefaultActions')
        self.assertEqual(len(default_actions), 1)

        default_action = default_actions[0]
        self.assertEqual(default_action.get('Type'), 'forward')

        target_group = LB.get_target_group(f'jarombek-com-{self.env}-lb-target')
        self.assertEqual(default_action.get('TargetGroupArn'), target_group.get('TargetGroupArn'))

    def test_target_group(self) -> None:
        """
        Prove that the target group for the load balancer is configured properly
        """
        target_group = LB.get_target_group(f'jarombek-com-{self.env}-lb-target')

        self.assertEqual(target_group.get('TargetGroupName'), f'jarombek-com-{self.env}-lb-target')
        self.assertEqual(target_group.get('Protocol'), 'HTTP')
        self.assertEqual(target_group.get('Port'), 8080)
        self.assertEqual(target_group.get('TargetType'), 'ip')

        self.assertEqual(target_group.get('HealthCheckProtocol'), 'HTTP')
        self.assertEqual(target_group.get('HealthCheckPort'), 8080)
        self.assertEqual(target_group.get('HealthCheckEnabled'), True)
        self.assertEqual(target_group.get('HealthCheckIntervalSeconds'), 10)
        self.assertEqual(target_group.get('HealthCheckTimeoutSeconds'), 5)
        self.assertEqual(target_group.get('HealthyThresholdCount'), 3)
        self.assertEqual(target_group.get('UnhealthyThresholdCount'), 2)
        self.assertEqual(target_group.get('HealthCheckPath'), '/')
        self.assertEqual(target_group.get('Matcher').get('HttpCode'), '200-299')

    def test_listener_https_certificate(self) -> None:
        pass
