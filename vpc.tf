resource "aws_vpc" "betaflux-test-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-betaflux-test-VPC"
  }
}

#####    Creating public sunets     ###########

resource "aws_subnet" "public-subnet-1" {
  cidr_block        = var.public_subnet-1_cidr
  vpc_id            = aws_vpc.betaflux-test-vpc.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.env}-public_subnet1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  cidr_block        = var.public_subnet-2_cidr
  vpc_id            = aws_vpc.betaflux-test-vpc.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.env}-public_subnet2"
  }
}

resource "aws_subnet" "public-subnet-3" {
  cidr_block        = var.public_subnet-3_cidr
  vpc_id            = aws_vpc.betaflux-test-vpc.id
  availability_zone = "us-east-1c"

  tags = {
    Name = "public_sunet3"
  }
}

#####    Creating private sunets     ###########

resource "aws_subnet" "private-subnet-1" {
  cidr_block        = var.private_subnet-1_cidr
  vpc_id            = aws_vpc.betaflux-test-vpc.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.env}-private_subnet1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  cidr_block        = var.private_subnet-2_cidr
  vpc_id            = aws_vpc.betaflux-test-vpc.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.env}-private_subnet2"
  }
}

resource "aws_subnet" "private-subnet-3" {
  cidr_block        = var.private_subnet-3_cidr
  vpc_id            = aws_vpc.betaflux-test-vpc.id
  availability_zone = "us-east-1c"

  tags = {
    Name = "${var.env}-private_sunet3"
  }
}

######    Creating public route table    #######

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.betaflux-test-vpc.id

  tags = {
    Name = "${var.env}-Public-Route-Table"
  }
}

######    Creating private route table    #######

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.betaflux-test-vpc.id

  tags = {
    Name = "${var.env}-private-Route-Table"
  }
}

######    subnet association with public route table    #######

resource "aws_route_table_association" "public-subnet1-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-1.id
}

resource "aws_route_table_association" "public-subnet2-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-2.id
}

resource "aws_route_table_association" "public-subnet3-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-3.id
}

######    subnet association with private route table    #######

resource "aws_route_table_association" "private-subnet1-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-1.id
}

resource "aws_route_table_association" "private-subnet2-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-2.id
}

resource "aws_route_table_association" "private-subnet3-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-3.id
}

######   Creating Elastic IP   #######

resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"

  tags = {
    Name = "${var.env}-betaflux-test-EIP"
  }
}

######    Creating NAT GW    #######

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "${var.env}-betaflux-test -NAT-GW"
  }

  depends_on = [aws_eip.elastic-ip-for-nat-gw]
}

###### Crating routes for NAT GW   ########

resource "aws_route" "nat-gw-route" {
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
}

###### Crating  IGW   ########

resource "aws_internet_gateway" "betaflux-test_igw" {
  vpc_id = aws_vpc.betaflux-test-vpc.id

  tags = {
    Name = "${var.env}-betaflux-test-IGW"
  }
}

###### Crating routes for IGW    ########

resource "aws_route" "public-internet-gateway-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.betaflux-test_igw.id
  destination_cidr_block = "0.0.0.0/0"

}

###### Crating Security groups   ########

resource "aws_security_group" "betaflux-test" {
  name        = "${var.env}-betaflux-test"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.betaflux-test-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-betaflux-test"
  }
}
