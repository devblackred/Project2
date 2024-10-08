
#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo yum install amazon-efs-utils -y
sudo systemctl start amazon-efs-utils
sudo systemctl enable amazon-efs-utils
sudo mkdir /mnt/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0d6ea7839554ca920.efs.us-east-1.amazonaws.com:/ /mnt/efs
echo "fs-0d6ea7839554ca920.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
sudo mkdir /mnt/efs/wordpress
cat <  /mnt/efs/docker-compose.yml
version: '3.8'
services:
wordpress:
image: wordpress:latest
container_name: wordpress
ports:
- "80:80"
environment:
WORDPRESS_DB_HOST: database-2.c9qoc6cw490u.us-east-1.rds.amazonaws.com
WORDPRESS_DB_USER: teste
WORDPRESS_DB_PASSWORD: teste123
WORDPRESS_DB_NAME: wordpress
WORDPRESS_TABLE_PREFIX: project_db
volumes:
- /mnt/efs/wordpress:/var/www/html
EOF
docker-compose -f /mnt/efs/docker-compose.yml up -d 2>> /home/ec2-user/log
