variable "tags" {
  default = ["control_node", "node_1", "node_2"]
}
variable "mykey" {
  default = "clarusway"
}
variable "user" {
  default = "clarusway"
}

variable "amznlnx2023" {
  default = "ami-0ae8f15ae66fe8cda"
}

variable "ubuntu" {
  default = "ami-04a81a99f5ec58529"
}

variable "instype" {
  default = "t2.micro"
}

# variable "aws_secret_key" {
#  default = "xxxxx"
# }

# variable "aws_access_key" {
#  default = "xxxxx"
# }