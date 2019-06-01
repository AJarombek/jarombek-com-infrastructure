"""
Helper functions to use for retrieving Load Balancer information.
Author: Andrew Jarombek
Date: 5/31/2019
"""

import boto3

elb = boto3.client('elbv2')


class LB:

    @staticmethod
    def get_load_balancer(name: str = '') -> dict:
        """
        Helper method which gets load balancer record information.
        :param name: the name of the load balancer.
        :return: A dictionary with information about a load balancer.
        :exception: Throws an IndexError if the load balancer does not exist
        """
        return LB.get_load_balancers(name)[0]

    @staticmethod
    def get_load_balancers(name: str = '') -> list:
        """
        Helper method which gets load balancer record information.
        :param name: the name of the load balancer.
        :return: a list of load balancers (dictionaries).
        :exception: Throws an IndexError if the load balancer does not exist
        """
        response = elb.describe_load_balancers(
            Names=[name]
        )
        return response.get('LoadBalancers')

    @staticmethod
    def get_listeners(lb_name: str = '') -> list:
        """
        Helper method which gets listeners for a load balancer
        :param lb_name: The name of the load balancer that the listener is attached to
        :return: a list of listeners attached to a load balancer
        """
        load_balancer = LB.get_load_balancer(lb_name)

        response = elb.describe_listeners(
            LoadBalancerArn=load_balancer.get('LoadBalancerArn')
        )
        return response.get('Listeners')

    @staticmethod
    def get_target_group(name: str = '') -> dict:
        """
        Get a single target group with a given name
        :param name: The name of the target group
        :return: a dictionary containing information about a target groups used by a load balancer listener
        """
        return LB.get_target_groups([name])[0]

    @staticmethod
    def get_target_groups(names: list) -> list:
        """
        Get a list of target groups with given names
        :param names: A list of names of target groups
        :return: a list of target groups used by load balancer listeners
        """
        return elb.describe_target_groups(
            Names=names
        )

    @staticmethod
    def get_listener_certs() -> list:
        """
        Get a list of ACM certificates associates with a load balancer listener
        :return: a list of certificates used by a load balancer listener
        """
        pass
