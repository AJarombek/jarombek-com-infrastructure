"""
Helper functions to use for retrieving Route53 information.
Author: Andrew Jarombek
Date: 4/28/2019
"""

import boto3

ecs = boto3.client('ecs')


class ECS:

    @staticmethod
    def get_clusters(names: list) -> list:
        """
        Retrieve the ECS clusters that match certain names or ARNs
        :param names: The names of ECS clusters on AWS
        :return: a list of clusters
        """
        return ecs.describe_clusters(clusters=[names]).get('clusters')

    @staticmethod
    def get_cluster(name: str) -> dict:
        """
        Retrieve an ECS cluster with a given name
        :param name: The name or ARN of the ECS cluster
        :return: a dictionary containing information about an ECS cluster
        """
        return ECS.get_clusters([name])[0]
