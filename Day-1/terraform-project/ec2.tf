resource "aws_instance" "t2_micro" {

  ami = var.ami

  instance_type = "t2.micro"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  key_name = var.key_name

  tags = {
    Name = "Terraform-T2-Micro"
  }

}

resource "aws_instance" "t2_large" {

  ami = var.ami

  instance_type = "t2.large"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  key_name = var.key_name

  tags = {
    Name = "Terraform-T2-Large"
  }

}

resource "aws_instance" "t3_large" {

  ami = var.ami

  instance_type = "t3.large"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  key_name = var.key_name

  tags = {
    Name = "Terraform-T3-Large"
  }

}

