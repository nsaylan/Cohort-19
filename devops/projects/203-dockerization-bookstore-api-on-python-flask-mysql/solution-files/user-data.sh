#!/bin/bash
dnf update
dnf install docker -y
dnf install git -y 
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
curl -SL https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
TOKEN=${user-data-git-token}
USER=${user-data-git-user-name}
cd /home/ec2-user/
git clone https://$TOKEN@github.com/$USER/bookstore-api-app
cd bookstore-api-app
docker build -t bookstore-api:latest .
docker-compose up -d


