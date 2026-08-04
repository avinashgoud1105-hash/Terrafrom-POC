output "vpc_id" {

  value = aws_vpc.main.id

}

output "public_subnet" {

  value = aws_subnet.public.id

}

output "private_subnet" {

  value = aws_subnet.private.id

}

output "public_ip_micro" {

  value = aws_instance.t2_micro.public_ip

}

output "public_ip_large" {

  value = aws_instance.t2_large.public_ip

}

output "public_ip_t3" {

  value = aws_instance.t3_large.public_ip

}
