#Creation of VPC
resource "aws_vpc" "main" {
        cidr_block = "10.0.0.0/16"
        tags = {
            Name = "main"
        }
}

#Creation of subnet
resource "aws_subnet" "public-subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet1"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-subnet2"
  }
}

resource "aws_subnet" "private-subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet1"
  }
}
resource "aws_subnet" "private-subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet2"
  }
}

#Creation of Elastic IP
resource "aws_eip" "Nat-Gateway-EIP" {

  depends_on = [
    aws_subnet.private-subnet2,
    aws_subnet.private-subnet1,
    aws_subnet.public-subnet1,
    aws_subnet.public-subnet2
  ]
  vpc = true
}


#Creation of IGW

resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_subnet.private-subnet2,
    aws_subnet.private-subnet1,
    aws_subnet.public-subnet1,
    aws_subnet.public-subnet2,
    aws_eip.Nat-Gateway-EIP
  ]

  # VPC in which it has to be created!
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW public subnet"
  }
}

#Creation of new NAT gateway
resource "aws_nat_gateway" "NAT_gateway" {
  depends_on = [
    aws_subnet.private-subnet2,
    aws_subnet.private-subnet1,
    aws_subnet.public-subnet1,
    aws_subnet.public-subnet2
  ]
  allocation_id = aws_eip.Nat-Gateway-EIP.id
  subnet_id = aws_subnet.private-subnet1.id
  tags = {
    Name = "Nat-Gateway_Project"
  }
}

#Public route table
resource "aws_route_table" "publicRouteTable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }


  tags = {
    Name = "public Route Table"
  }
}

#Private route table
resource "aws_route_table" "privarteRouteTable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_gateway.id
  }


  tags = {
    Name = "private Route Table"
  }
}

#Public Route table subnet association

resource "aws_route_table_association" "publicsubnet1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.publicRouteTable.id
}

resource "aws_route_table_association" "publicsubnet2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.publicRouteTable.id
}

#Private subnet association
resource "aws_route_table_association" "privatesubnet1" {
  subnet_id      = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.privarteRouteTable.id
}

resource "aws_route_table_association" "privatesubnet2" {
  subnet_id      = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.privarteRouteTable.id
}


resource "aws_security_group" "allow_ssh" {
  name        = "allow_inbound_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from anywhere"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
  }

  tags = {
    Name = "allow_outbound_ssh"
  }
}
