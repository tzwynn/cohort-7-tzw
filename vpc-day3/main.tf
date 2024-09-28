resource "aws_vpc" "c7-vault-vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "c7-vault-vpc"
  }
}

resource "aws_subnet" "c7-public-subnet" {
  count                   = length(var.public-cidr-block)
  vpc_id                  = aws_vpc.c7-vault-vpc.id
  cidr_block              = var.public-cidr-block[count.index]
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "c7-public-subnet-${element(data.aws_availability_zones.azs.names, count.index)}"
  }
}

resource "aws_route_table" "c7-public-rt" {
  vpc_id = aws_vpc.c7-vault-vpc.id
  tags = {
    Name = "c7-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public-cidr-block)
  subnet_id      = aws_subnet.c7-public-subnet[count.index].id
  route_table_id = aws_route_table.c7-public-rt.id
}

resource "aws_internet_gateway" "c7-public-gw" {
  vpc_id = aws_vpc.c7-vault-vpc.id

  tags = {
    Name = "c7-public-gw"
  }
}

resource "aws_route" "c7-route" {
  route_table_id         = aws_route_table.c7-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.c7-public-gw.id
}

#private subnet

resource "aws_subnet" "c7-private-subnet" {
  count             = length(var.private-cidr-block)
  vpc_id            = aws_vpc.c7-vault-vpc.id
  cidr_block        = var.private-cidr-block[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "c7-private-subnet-${element(data.aws_availability_zones.azs.names, count.index)}"
  }
}

resource "aws_route_table" "c7-private-rt" {
  vpc_id = aws_vpc.c7-vault-vpc.id
  tags = {
    Name = "c7-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private-cidr-block)
  subnet_id      = aws_subnet.c7-private-subnet[count.index].id
  route_table_id = aws_route_table.c7-private-rt.id
}

resource "aws_eip" "c7-eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "c7-nat-gw" {
  allocation_id = aws_eip.c7-eip.id
  subnet_id     = aws_subnet.c7-public-subnet[0].id

  tags = {
    Name = "c7-nat-gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.c7-public-gw]
}

resource "aws_route" "c7-private-route" {
  route_table_id         = aws_route_table.c7-private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.c7-nat-gw.id
}

#creating a database subnet

resource "aws_subnet" "c7-db-subnet" {
  count             = length(var.db-cidr-block)
  vpc_id            = aws_vpc.c7-vault-vpc.id
  cidr_block        = var.db-cidr-block[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "c7-db-subnet-${element(data.aws_availability_zones.azs.names, count.index)}"
  }
}

resource "aws_route_table" "c7-db-rt" {
  vpc_id = aws_vpc.c7-vault-vpc.id
  tags = {
    Name = "c7-db-rt"
  }
}

resource "aws_route_table_association" "db" {
  count          = length(var.db-cidr-block)
  subnet_id      = aws_subnet.c7-db-subnet[count.index].id
  route_table_id = aws_route_table.c7-db-rt.id
}

resource "aws_route" "c7-db-route" {
  route_table_id         = aws_route_table.c7-db-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.c7-nat-gw.id
}

resource "aws_db_subnet_group" "c7-db-subnet-group" {
  name       = "c7-db-group"
  subnet_ids = aws_subnet.c7-db-subnet[*].id

  tags = {
    Name = "c7 DB subnet group"
  }
}