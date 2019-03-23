#!/usr/bin/env bash

# Install Ansible for use in the Packer AMI
# Author: Andrew Jarombek
# Date: 3/22/2019

sleep 30

apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt-get -y install ansible