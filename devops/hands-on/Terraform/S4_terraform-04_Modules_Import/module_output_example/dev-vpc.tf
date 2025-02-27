module "tf-vpc" {
  source = "../modules"
  environment = "DEV"
  }

output "vpc-cidr-block" {
  value = module.tf-vpc.vpc_cidr
}


resource "aws_instance" "tf-instances" {
  ami = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  subnet_id = module.tf-vpc.public_subnet_id
}