//variable "aws_secret_key" {}
//variable "aws_access_key" {}

variable "region" {
  default = "us-east-1"
}

variable "mykey" {
  default = "mykey"
}

variable "instancetype" {
  default = "t2.micro"
}

variable "secgrname" {
  default = "TomcatServerSecurityGroup"
}
