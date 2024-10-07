#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
curl -sL "https://raw.githubusercontent.com/devblackred/Project2-/main/dockercompose.yml" --output "/home/ec2-user/dockercompose.yaml"
sudo chmod +x /usr/local/bin/docker-compose
sudo mv /usr/local/bin/docker-compose /bin/docker-compose
sudo yum install nfs-utils -y
sudo mkdir /mnt/efs/
sudo chmod +rwx /mnt/efs/
