terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "devserver" {
  ami =    "ami-0a695f0d95cefc163"
  instance_type = "t2.micro"
  tags = {
    Name = "TF-instance"

  }
}

resource "aws_key_pair" "devkey" {
  key_name = var.devkey
  public_key = var.public_key
}