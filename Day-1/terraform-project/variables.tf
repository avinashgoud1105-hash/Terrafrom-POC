variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  default = "10.0.1.0/24"
}

variable "private_subnet" {
  default = "10.0.2.0/24"
}

variable "ami" {
  default = "ami-0126975fb247bf2e7"
}

variable "key_name" {
  default = "Terraform_Setup"
}
