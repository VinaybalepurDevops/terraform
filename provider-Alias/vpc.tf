#Creation of VPC
resource "aws_vpc" "main" {
        cidr_block = "10.0.0.0/16"
        tags = {
            Name = "main"
        }
}

#Creation of backup VPC
resource "aws_vpc" "backup" {
        provider = aws.backup
        cidr_block = "10.0.0.0/16"
        tags = {
            Name = "backup"
        }
}

#Creation of subnet
resource "aws_subnet" "main-public-subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "main-public-subnet1"
  }
}

#Creation of subnet in backup region
resource "aws_subnet" "backup-public-subnet1" {
  provider = aws.backup
  vpc_id     = aws_vpc.backup.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1a"
  tags = {
    Name = "backup-public-subnet1"
  }
}
