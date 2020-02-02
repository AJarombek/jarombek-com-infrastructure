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
from utils.SecurityGroup import SecurityGroup
from utils.ECS import ECS


class TestJarombekCom(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ec2 = boto3.client('ec2')
        self.route53 = boto3.client('route53')
        self.elb = boto3.client('elbv2')
        self.acm = boto3.client('acm')
        self.acm_certificates = self.acm.list_certificates(CertificateStatuses=['ISSUED']).get('CertificateSummaryList')

        try:
            prod_env = os.environ['TEST_ENV'] == "prod"
        except KeyError:
            prod_env = True

        if prod_env:
            self.env = "prod"
            self.website_url = "jarombek.com"
            self.cert_url = "jarombek.com"
            self.wc_cert_url = "*.jarombek.com"
            self.lb_certs = [cert for cert in self.acm_certificates if cert.get('DomainName') == self.cert_url
                             or cert.get('DomainName') == self.wc_cert_url]
        else:
            self.env = "dev"
            self.website_url = "dev.jarombek.com"
            self.cert_url = "*.jarombek.com"
            self.wc_cert_url = "*.dev.jarombek.com"
            self.lb_certs = [cert for cert in self.acm_certificates if cert.get('DomainName') == self.cert_url
                             or cert.get('DomainName') == self.wc_cert_url]

    def test_jarombek_com_a_record_exists(self) -> None:
        """
        Determine if the 'A' record exists for the website in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.com.', self.website_url, 'A')
        except IndexError:
            self.assertFalse(True)

        self.assertEqual(a_record.get('Name'), f'{self.website_url}.')
        self.assertEqual(a_record.get('Type'), 'A')

    def test_www_jarombek_com_cname_record_exists(self) -> None:
        """
        Determine if the 'CNAME' record exists for the 'www' prefixed website in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.com.', f'www.{self.website_url}', 'CNAME')
        except IndexError:
            self.assertFalse(True)

        self.assertEqual(a_record.get('Name'), f'www.{self.website_url}.')
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
        self.assertEqual(default_action.get('RedirectConfig').get('Port'), '443')
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
        self.assertEqual(target_group.get('HealthCheckPort'), '8080')
        self.assertEqual(target_group.get('HealthCheckEnabled'), True)
        self.assertEqual(target_group.get('HealthCheckIntervalSeconds'), 10)
        self.assertEqual(target_group.get('HealthCheckTimeoutSeconds'), 5)
        self.assertEqual(target_group.get('HealthyThresholdCount'), 3)
        self.assertEqual(target_group.get('UnhealthyThresholdCount'), 2)
        self.assertEqual(target_group.get('HealthCheckPath'), '/')
        self.assertEqual(target_group.get('Matcher').get('HttpCode'), '200-299')

    def test_listener_https_certificate(self) -> None:
        """
        Prove that the HTTPS listener for the load balancer has the expected ACM certificate
        """
        certs = LB.get_listener_certs(lb_name=f'jarombek-com-{self.env}-alb')
        self.assertEqual(len(certs), 2)

        cert = certs[0]
        self.assertEqual(cert.get('CertificateArn'), self.lb_certs[1].get('CertificateArn'))

        cert = certs[1]
        self.assertEqual(cert.get('CertificateArn'), self.lb_certs[0].get('CertificateArn'))

    def test_lb_security_group_exists(self) -> None:
        """
        Prove that the security group for the load balancer exists
        """
        security_groups = SecurityGroup.get_security_groups(name=f'jarombek-com-{self.env}-lb-security-group')
        self.assertEqual(len(security_groups), 1)

        sg = security_groups[0]
        self.assertEqual(sg.get('GroupName'), f'jarombek-com-{self.env}-lb-security-group')

    def test_lb_security_group_rules_exist(self) -> None:
        """
        Prove that the security group rules for the load balancer exist as expected
        """
        sg = SecurityGroup.get_security_groups(name=f'jarombek-com-{self.env}-lb-security-group')[0]

        ingress = sg.get('IpPermissions')
        egress = sg.get('IpPermissionsEgress')

        self.test_sg_rule_cidr(ingress[0], 'tcp', 80, 80, '0.0.0.0/0')
        self.test_sg_rule_cidr(ingress[1], 'tcp', 443, 443, '0.0.0.0/0')
        self.test_sg_rule_cidr(egress[0], '-1', 0, 0, '0.0.0.0/0')

    def test_ecs_cluster_running(self) -> None:
        """
        Prove that the ECS cluster for the website is up and running as expected
        """
        cluster = ECS.get_cluster(f'jarombek-com-{self.env}-ecs-cluster')
        self.assertEqual(cluster.get('clusterName'), f'jarombek-com-{self.env}-ecs-cluster')
        self.assertEqual(cluster.get('status'), 'ACTIVE')

    def test_ecs_task_running(self) -> None:
        """
        Prove that the ECS task for the website and database is up and running as expected
        """
        tasks = ECS.get_tasks(f'jarombek-com-{self.env}-ecs-cluster', 'jarombek-com')
        self.assertEqual(len(tasks), 1)

        task = tasks[0]
        self.assertEqual(task.get('lastStatus'), 'RUNNING')
        self.assertEqual(task.get('desiredStatus'), 'RUNNING')

        containers = task.get('containers')
        self.assertEqual(len(containers), 2)

        jarombek_com_container = containers[0]
        self.assertEqual(jarombek_com_container.get('name'), 'jarombek-com-database')
        self.assertEqual(jarombek_com_container.get('lastStatus'), 'RUNNING')

        jarombek_com_database_container = containers[1]
        self.assertEqual(jarombek_com_database_container.get('name'), 'jarombek-com')
        self.assertEqual(jarombek_com_database_container.get('lastStatus'), 'RUNNING')

    def test_ecs_service_running(self) -> None:
        """
        Prove that the ECS service for the website and database is up and running as expected
        """
        services = ECS.get_services(
            cluster_name=f'jarombek-com-{self.env}-ecs-cluster',
            service_names=[f'jarombek-com-ecs-{self.env}-service']
        )
        self.assertEqual(len(services), 1)

        service = services[0]
        self.assertEqual(service.get('serviceName'), f'jarombek-com-ecs-{self.env}-service')
        self.assertEqual(service.get('launchType'), 'FARGATE')
        self.assertEqual(service.get('status'), 'ACTIVE')
        self.assertEqual(service.get('desiredCount'), 1)
        self.assertEqual(service.get('runningCount'), 1)
        self.assertEqual(service.get('pendingCount'), 0)

    @unittest.skip("helper function")
    def test_sg_rule_cidr(self, rule: dict, protocol: str, from_port: int, to_port: int, cidr: str) -> None:
        """
        Determine if a security group rule which opens connections
        from (ingress) or to (egress) a CIDR block exists as expected.
        :param rule: A dictionary containing security group rule information
        :param protocol: Which protocol the rule enables connections for
        :param from_port: Lowest # port the rule enables connections for
        :param to_port: Highest # port the rule enables connections for
        :param cidr: The ingress or egress CIDR block
        """
        if from_port == 0:
            from_port_valid = 'FromPort' not in rule.keys()
        else:
            from_port_valid = rule.get('FromPort') == from_port

        if to_port == 0:
            to_port_valid = 'ToPort' not in rule.keys()
        else:
            to_port_valid = rule.get('ToPort') == to_port

        self.assertEqual(rule.get('IpProtocol'), protocol)
        self.assertTrue(from_port_valid)
        self.assertTrue(to_port_valid)
        self.assertEqual(rule.get('IpRanges')[0].get('CidrIp'), cidr)
