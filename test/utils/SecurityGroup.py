"""
Helper functions for Security Groups
Author: Andrew Jarombek
Date: 6/1/2019
"""

import boto3

ec2 = boto3.client('ec2')


class SecurityGroup:

    @staticmethod
    def get_security_groups(name: str) -> list:
        """
        Get a list of Security Groups that match a given name
        :param name: Name of the Security Group in AWS
        :return: A list of Security Group objects (dictionaries)
        """
        security_groups = ec2.describe_security_groups(
            Filters=[{
                'Name': 'tag:Name',
                'Values': [name]
            }]
        )
        return security_groups.get('SecurityGroups')