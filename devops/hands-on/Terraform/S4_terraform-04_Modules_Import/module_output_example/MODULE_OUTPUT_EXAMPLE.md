- Add following block to the `terraform-modules/modules/main.tf` file.

```go
output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}
```

- Add following block to the `terraform-modules/dev/dev-vpc.tf` file.

```go
resource "aws_instance" "tf-instances" {
  ami = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  subnet_id = module.tf-vpc.public_subnet_id
}
```