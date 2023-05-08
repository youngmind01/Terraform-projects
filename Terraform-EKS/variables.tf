variable "my-region" {
    description = "EC2 region"
    default = "us-east-2"
    type = string
}

variable "os_name" {
  default = "ami-0a695f0d95cefc163"
  type = string
}

variable "key" {
  default = "eks-key"
  type = string
}

variable "instance-type" {
  default = "t2.small"
  type = string
}

variable "dev-vpc" {
  default = "10.10.0.0/16"
  type = string
}

variable "dev-subnet" {
  default = "10.10.1.0/24"
  type = string
}

variable "subnet-az" {
  default = "us-east-2a"
  type = string
}