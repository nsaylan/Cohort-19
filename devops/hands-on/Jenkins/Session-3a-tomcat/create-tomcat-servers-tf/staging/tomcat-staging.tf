//This Terraform config file creates 2 Tomcat Server (Stage and Production) on EC2 Instance. Applicable in N. Virginia(us-east-1).

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
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

resource "aws_instance" "tomcat-server" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instancetype
  key_name      = var.mykey
  vpc_security_group_ids = [aws_security_group.tf-tomcat-sec-gr.id]
  user_data = file("userdata.sh")
  tags = {
    Name = "tomcat-staging-server"
  }

}

resource "aws_security_group" "tf-tomcat-sec-gr" {
  name = var.secgrname
  tags = {
    Name = var.secgrname
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
