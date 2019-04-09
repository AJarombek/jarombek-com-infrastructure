#!/usr/bin/env bash

# Use cases for the Bastion host
# Author: Andrew Jarombek
# Date: 4/7/2019

# Connect to the Bastion host using agent forwarding
cd ~/Documents/
sudo ssh -A ec2-user@ec2-xxx-xxx-xxx-xxx.compute-1.amazonaws.com

# From inside the Bastion host, connect to an EC2 instance in the private subnet
ssh ec2-user@ec2-xxx-xxx-xxx-xxx.compute-1.amazonaws.com

# On the mongodb instance, test that mongo is running
mongo

# Debug UserData and AWS::CloudFormation::Init
sudo nano /var/log/cloud-init-output.log
sudo nano /var/log/cfn-init.log

# Test connecting to GitHub with SSH
ssh -T git@github.com

# Try running AWS::CloudFormation::Init again
sudo /opt/aws/bin/cfn-init -v -s jarombek-com-mongodb-dev -r MongoDBInstance -c default --region us-east-1
git clone git@github.com:AJarombek/jarombek-com-database.git