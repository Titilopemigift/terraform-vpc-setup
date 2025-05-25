#vpc setup
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "Titilope"
    Team = "Data Engineering Team"
  }
}

#created public and private subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.2.0.0/24"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.2.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Titilope"
  }
}

#Route table
resource "aws_route_table" "titilope_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Titilope"
  }
}

#Route table association
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.titilope_route_table.id
}
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.titilope_route_table.id
}

#Security group(ingress and egress)
resource "aws_security_group" "security_group" {
  name        = "my_security_group"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id
  
  tags = {
    Name = "allow_ssh"
  }

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

