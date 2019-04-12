#!/usr/bin/env bash

# Install Nginx and Node.js for the application
# Author: Andrew Jarombek
# Date: 4/10/2019

# Install Nginx
amazon-linux-extras install nginx1.12
systemctl enable nginx

# Install nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash

# Install Node.js
. ~/.nvm/nvm.sh
nvm install 8.11.3
node -v

# Install Global npm Modules
npm install yarn -g
yarn --version
echo "export PATH=\"\$PATH:`yarn global bin`\"" >> .bash_profile

npm install pm2 -g
pm2 ls

# Add CertBot Repository
curl -O http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install CertBot
sudo yum -y install epel-release-latest-7.noarch.rpm
sudo yum -y install certbot
sudo yum -y install python2-certbot-nginx

# Install Git
sudo yum -y install git