#!/usr/bin/env bash

# Install Ansible for use in the Packer AMI
# Author: Andrew Jarombek
# Date: 3/22/2019

sleep 30

sudo yum -y update
sudo yum -y install python-pip
sudo pip install ansible