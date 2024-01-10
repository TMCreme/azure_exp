#!/bin/sh

set -e 

echo "run apt update "
sudo apt-get update

echo "Installing dependencies"
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "Starting the installations "
echo "Installing git"
sudo apt install -y git

### Download the docker gpg file to Ubuntu
echo "Download the docker gpg"
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

### Add Docker and docker compose support to the Ubuntu's packages list
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
 
### Install docker and docker compose on Ubuntu
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo systemctl enable docker.service
sudo systemctl start docker.service

sudo usermod -aG docker ubuntu

