#!/usr/bin/env bash

# Handle certbot certificate generation for a given environment
# Author: Andrew Jarombek
# Date: 3/27/2019

[[ -z "$1" ]] && ( echo "Argument 1 (Required): 'Environment' not specified." && exit 1 )
ENV=$1

if [[ "$ENV" = "dev" ]]
then
    URL="dev.jarombek.com"
else
    URL="jarombek.com"
fi

# Set up HTTPS for Nginx
sudo certbot --nginx --agree-tos --email andrew@jarombek.com -d ${URL} --redirect