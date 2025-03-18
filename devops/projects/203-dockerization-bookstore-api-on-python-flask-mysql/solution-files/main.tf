terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.91.0"
    }

    github = {
      source = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "github" {
  token = var.git-token
}

variable "git-token" {
    default = "ghp_xWMT1p" # update with your token!!!!!!  
}

variable "key-name" {
  default = "davidskey"  # update with your key name !!!!!!
}

variable "git-user-name" {
    default = "davidinst"  # update with your github user name!!!!!! 
}


resource "github_repository" "myrepo" {
  name = "bookstore-api-app"
  visibility = "private"
  description = "managed by Terraform"
  auto_init = true
}

resource "github_branch_default" "mydefaultbranch" {
    branch = "main"
    repository = github_repository.myrepo.name
}

variable "files" {
    default = ["bookstore-api.py", "requirements.txt", "Dockerfile", "compose.yml"]
}

resource "github_repository_file" "app-files" {
    for_each = toset(var.files)
    file =  each.value
    content = file(each.value)
    repository = github_repository.myrepo.name
    branch = "main"
    commit_message = "managed by Terraform"
    overwrite_on_create = true
}

resource "aws_security_group" "tf-docker-sg" {
    name = "docker-sec-gr-203-CH19"
    tags = {
        Name = "project-203-docker"
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "tf-docker-ec2" {
    ami = "ami-0e731c8a588258d0d"
    instance_type = "t2.micro"
    key_name = var.key-name
    vpc_security_group_ids = [ aws_security_group.tf-docker-sg.id ]
    tags = {
      Name = "David's Web Server of Bookstore"
    }
    user_data = templatefile("user-data.sh", {user-data-git-token = var.git-token, user-data-git-user-name = var.git-user-name})
    depends_on = [ github_repository.myrepo, github_repository_file.app-files ]
}

output "webserver-url" {
  value = "http://${aws_instance.tf-docker-ec2.public_ip}"
}