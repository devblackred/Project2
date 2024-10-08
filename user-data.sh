#!/bin/bash
sudo su
yum update -y
yum install docker -y
yum install nfs-utils -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
curl -sL "https://raw.githubusercontent.com/devblackred/Project2-CompassUOL/main/docker-compose.yml" --output /home/ec2-user/docker-compose.yml
chmod +x /usr/local/bin/docker-compose
mv /usr/local/bin/docker-compose /bin/docker-compose
mkdir /mnt/efs/wordpress
chmod +rwx /mnt/efs/
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0d6ea7839554ca920.efs.us-east-1.amazonaws.com:/ /mnt/efs
echo "fs-0d6ea7839554ca920.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
mysql --host="wordpress.ct8i8oe2sycs.us-east-1.rds.amazonaws.com" --user="teste" --password="teste123" --execute="CREATE DATABASE IF NOT EXISTS wordpress;"
cd /home/ec2-user
docker-compose up -d
