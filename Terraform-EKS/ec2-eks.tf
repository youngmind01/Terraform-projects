provider "aws" {
  region = var.my-region
}

//  VPC
resource "aws_vpc" "dev-vpc" {
  cidr_block = var.dev-vpc
}

//  Subnet
resource "aws_subnet" "dev_subnet" {
  vpc_id            = var.dev-vpc
  cidr_block        = var.dev-subnet
  availability_zone = var.subnet-az

  tags = {
    name = "dev_subnet"
  }
}

// Internet gateway 
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-igw"
  }
}

// route table
resource "aws_route_table" "dev-rt" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.dev-igw.id
  }

  tags = {
    Name = "dev-rt"
  }
}

// associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.dev_subnet.id
  route_table_id = aws_route_table.dev-rt.id
}

// security group
resource "aws_security_group" "dev-vpc-sg" {
  name        = "allow ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

// Instance resource
resource "aws_instance" "eks-server" {
  ami                         = var.os_name
  instance_type               = var.instance-type
  key_name                    = var.key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.dev_subnet.id
  vpc_security_group_ids      = [aws_security_group.dev-vpc-sg.id]
}

module "sgs" {
  source = "./sg_eks"
  vpc_id = aws_vpc.dev-vpc.id
}

module "eks" {
  source     = "./eks"
  sg-ids     = module.sgs.security_group_public
  vpc_id     = aws_vpc.dev-vpc
  subnet-ids = aws_subnet.dev_subnet.id
}