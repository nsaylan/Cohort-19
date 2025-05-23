//This Terraform Template creates an EC2 Instance with Java-11 and Maven.
//Amazon Linux 2023 will be used as an EC2 Instance with
//custom security group allowing SSH connections from anywhere on port 22.

provider "aws" {
  region = "us-east-1"
  //  access_key = ""
  //  secret_key = ""
  //  If you have entered your credentials in AWS CLI before, you do not need to use these arguments.
}

locals {
  inst_type = "t3a.medium"
  pem       = "key-name"    # change this part with your key.
  user      = "clarusway"
}

data "aws_ami" "al2023" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name = "architecture"
    values = ["x86_64"]
  } 
  
  filter {
    name = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "maven-ec2" {
  ami             = data.aws_ami.al2023.id
  instance_type   = local.inst_type
  key_name        = local.pem
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]

  tags = {
    Name = "Maven-${local.user}"
  }

  user_data = <<-EOF
          #! /bin/bash
          yum update -y
          #Install java
          yum install java-17-amazon-corretto-devel -y
          #Install maven
          cd /home/ec2-user/
          wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
          tar -zxvf $(ls | grep apache-maven-*-bin.tar.gz)
          rm -rf $(ls | grep apache-maven-*-bin.tar.gz)
          echo "M2_HOME=/home/ec2-user/$(ls | grep apache-maven)" >> /home/ec2-user/.bash_profile
          echo 'export PATH=$PATH:$M2_HOME/bin' >> /home/ec2-user/.bash_profile
          # Install docker
          yum install docker -y
          systemctl start docker
          systemctl enable docker
          usermod -a -G docker ec2-user
          # install docker-compose
          curl -SL https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          EOF
}

data "aws_vpc" "selected" {
  default = true
}
  
  
resource "aws_security_group" "tf-sec-gr" {
  name = "${local.user}-maven-sec-grp"
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Name = "${local.user}-maven-sec-grp"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
