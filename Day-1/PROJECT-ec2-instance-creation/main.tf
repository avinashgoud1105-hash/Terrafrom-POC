provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "t2_micro" {
  ami           = "ami-0126975fb247bf2e7"
  instance_type = "t2.micro"

  tags = {
    Name = "Avinash_Terraform-T2-Micro"
  }
}

resource "aws_instance" "t2_large" {
  ami           = "ami-0126975fb247bf2e7"
  instance_type = "t2.large"

  tags = {
    Name = "Avinash_Terraform-T2-Large"
  }
}

resource "aws_instance" "t3_large" {
  ami           = "ami-0126975fb247bf2e7"
  instance_type = "t3.large"

  tags = {
    Name = "AvinashTerraform-T3-Large"
  }
}
