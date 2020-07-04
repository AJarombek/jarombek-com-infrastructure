"""
Unit tests for the IAM roles and policies created for the jarombek.com infrastructure
Author: Andrew Jarombek
Date: 5/27/2019
"""

import unittest
import boto3


class TestIAM(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.iam = boto3.client('iam')

    def test_ecs_task_role_exists(self) -> None:
        """
        Test that the ecs-task-role IAM Role exists
        """
        role_dict = self.iam.get_role(RoleName='ecs-task-role')
        role = role_dict.get('Role')
        self.assertEqual(role.get('Path'), '/admin/')
        self.assertEqual(role.get('RoleName'), 'ecs-task-role')

    def test_ecs_task_policy_attached(self) -> None:
        """
        Test that the ecs-task-policy is attached to the ecs-task-role
        """
        policy_response = self.iam.list_attached_role_policies(RoleName='ecs-task-role')
        policies = policy_response.get('AttachedPolicies')
        ecs_policy = policies[0]
        self.assertEqual(len(policies), 1)
        self.assertEqual(ecs_policy.get('PolicyName'), 'ecs-task-policy')
