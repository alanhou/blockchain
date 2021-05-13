#!/bin/bash
# Installs node JS and the utilities
# Updated : Fabric 2.x : April 2020
# https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-18-04

mkdir temp &> /dev/null
cd temp

# Get NVM
curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.35.3/install.sh -o install_nvm.sh

# Install NVM
bash install_nvm.sh

# Include the function
source ~/.nvm/nvm.sh

# Install the LTS
nvm install 12.18.3

# Switch to the LTS
nvm use 12.18.3

echo "nvm use 12.18.3" >> ~/.profile
echo "nvm use 12.18.3" >> ~/.bashrc

# sudo apt-get install g++ -y

# source ~/.profile
# source ~/.bashrc