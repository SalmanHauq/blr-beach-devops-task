#!/bin/bash

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
sudo systemctl status docker

#Docker Image pull and run
sudo docker pull salmanhauq/spring-petclinic
sudo docker run -d -p 8080:8080 salmanhauq/spring-petclinic
