#!/usr/bin/env bash

# Generate a public and private key for accessing private repositories on GitHub.
# NOTE: When executed with Terraform, make sure the script has super user privileges.
# Run the command `sudo -s` beforehand.
# Author: Andrew Jarombek
# Date: 4/5/2019

# The key to generate is determined by a command line argument.  First validate the argument...
[[ -z "$1" ]] && ( echo "Argument 1 (Required): 'Key Name' not specified." && exit 1 )

# ... then collect it
KEY_NAME=$1

IFS=

# Generate a public and private SSH key without prompting
ssh-keygen -f ${KEY_NAME} -t rsa -N ''

# Copy the SSH keys so they can be easily placed on GitHub and the mongodb EC2 instance
cp ${KEY_NAME} ../database/modules/mongodb/cred/${KEY_NAME}
rm ${KEY_NAME}

cp ${KEY_NAME}.pub ../database/modules/mongodb/cred/${KEY_NAME}.pub
rm ${KEY_NAME}.pub