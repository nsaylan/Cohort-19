terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_instance" "tomcat" {

  filter {
    name   = "tag:Name"
    values = ["tomcat-staging-server"]
  }
}

locals {
  instance-type= "t2.micro"
  my-key= "mykey"
  sec-gr= "tomcat-prod-sec-gr"
}

resource "aws_ami_from_instance" "tomcat-ami" {
  name               = "tomcat-ami"
  source_instance_id = data.aws_instance.tomcat.id
}

resource "aws_instance" "prod-tomcat" {
   ami = aws_ami_from_instance.tomcat-ami.id
   instance_type = local.instance-type
   key_name      = local.my-key
   vpc_security_group_ids = [aws_security_group.tf-tomcat-prod-sec-gr.id]
   tags = {
     Name = "tomcat-production-server"
   }
}

resource "aws_security_group" "tf-tomcat-prod-sec-gr" {
  name = local.sec-gr
  tags = {
    Name = local.sec-gr
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}