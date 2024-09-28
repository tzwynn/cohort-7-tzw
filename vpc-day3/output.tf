output "vpc_id" {
  value = aws_vpc.c7-vault-vpc.id

}

output "vpc_public_subnet" {
  value = aws_subnet.c7-public-subnet[*].id

}