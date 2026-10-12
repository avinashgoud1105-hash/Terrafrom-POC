provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "t2_micro" {
  ami           = "ami-0ab62641f58457061"
  instance_type = "t2.micro"

  tags = {
    Name = "Avinash_Terraform-T2-Micro"
  }
}

