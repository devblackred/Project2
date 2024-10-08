#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo yum install nfs-utils -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo curl -sL "https://raw.githubusercontent.com/devblackred/Project2-CompassUOL/main/docker-compose.yml" --output /home/ec2-user/docker-compose.yml
sudo chmod +x /usr/local/bin/docker-compose
sudo mv /usr/local/bin/docker-compose /bin/docker-compose
sudo mkdir /mnt/efs/wordpress
sudo chmod +rwx /mnt/efs/
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0d6ea7839554ca920.efs.us-east-1.amazonaws.com:/ /mnt/efs
sudo echo "fs-0d6ea7839554ca920.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
sudo mysql --host="wordpress.ct8i8oe2sycs.us-east-1.rds.amazonaws.com" --user="teste" --password="teste123" --execute="CREATE DATABASE IF NOT EXISTS wordpress;"
sudo cd /home/ec2-user
sudo docker-compose up -d
