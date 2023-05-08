provider "aws" {
  region = "us-east-2"
}

# resource "aws_key_pair" "devkey" {
#   key_name   = "devkey"
#   public_key = tls_private_key.dev.public_key_openssh
# }

# resource "tls_private_key" "dev" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "local_file" "devkey" {
#   content         = tls_private_key.dev.public_key_pem
#   filename        = "devkey.pem"
#   file_permission = "700"
# }



# create vpc 

resource "aws_vpc" "dev-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dev-vpc"
  }
}

# create internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev"
  }
}

# create custom route table
resource "aws_route_table" "dev-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "dev"
  }
}

# create a subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.subnet_prefix[0]
  availability_zone = "us-east-2a"

  tags = {
    Name = "dev-subnet"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.subnet_prefix[1]
  availability_zone = "us-east-2a"

  tags = {
    Name = "dev-subnet"
  }
}


# associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.dev-route-table.id
}

# create security group to allow port 22,80,443

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.main.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# assign an elastic ip to the network interface created in step 7
resource "aws_eip" "one" {
  instance                  = aws_instance.devserver.id
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  vpc                       = true

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_instance" "devserver" {
  ami               = "ami-0a695f0d95cefc163"
  instance_type     = "t2.micro"
  availability_zone = "us-east-2a"
  key_name          = "devKey"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
          #!/bin/bash
          sudo apt update
          sudo apt install apache2 -y
          sudo systemctl start apache2
          sudo systemctl enable apache2
          sudo bash -c 'echo Terraform made easy > /var/www/html/index.html'
          EOF
  tags = {
    name = "web server"
  }

}