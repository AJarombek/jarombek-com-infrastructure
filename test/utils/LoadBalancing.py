"""
Helper functions to use for retrieving Load Balancer information.
Author: Andrew Jarombek
Date: 5/31/2019
"""

import boto3

elb = boto3.client('elbv2')


class LB:

    @staticmethod
    def get_load_balancer(name: str) -> dict:
        """
        Helper method which gets load balancer record information.
        :param name: the name of the load balancer.
        :exception: Throws an IndexError if the load balancer does not exist
        """
        return LB.get_load_balancers(name)[0]

    @staticmethod
    def get_load_balancers(name: str) -> list:
        """
        Helper method which gets load balancer record information.
        :param name: the name of the load balancer.
        :exception: Throws an IndexError if the load balancer does not exist
        """
        response = elb.describe_load_balancers(
            Names=[name]
        )
        return response.get('LoadBalancers')

    @staticmethod
    def get_listeners(lb_name: str) -> str:
        pass
