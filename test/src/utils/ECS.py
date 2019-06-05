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
        return ecs.describe_clusters(clusters=names).get('clusters')

    @staticmethod
    def get_cluster(name: str) -> dict:
        """
        Retrieve an ECS cluster with a given name
        :param name: The name or ARN of the ECS cluster
        :return: a dictionary containing information about an ECS cluster
        """
        return ECS.get_clusters([name])[0]

    @staticmethod
    def get_tasks(cluster_name: str, family: str) -> list:
        """
        Retrieve a list of tasks in an ECS cluster
        :param cluster_name: The name of the cluster containing the tasks
        :param family: Family that the task resides in
        :return: a list of tasks
        """
        task_arn_list = ecs.list_tasks(
            cluster=cluster_name,
            family=family,
            desiredStatus='RUNNING'
        )

        task_list = ecs.describe_tasks(
            cluster=cluster_name,
            tasks=task_arn_list.get('taskArns')
        )

        return task_list.get('tasks')

    @staticmethod
    def get_services(cluster_name: str, service_names: list) -> list:
        """
        Get a list of services in an ECS cluster
        :param cluster_name: The name of the cluster containing the services
        :param service_names: A list containing names of services
        :return: a list of services
        """
        services = ecs.describe_services(
            cluster=cluster_name,
            services=service_names
        )
        return services.get('services')

    @staticmethod
    def get_service(cluster_name: str, service_name: str) -> dict:
        """
        Get a service in an ECS cluster
        :param cluster_name: The name of the cluster containing the service
        :param service_name: The name of the service
        :return: a dictionary containing information about a service
        """
        return ECS.get_services(cluster_name, [service_name])[0]
