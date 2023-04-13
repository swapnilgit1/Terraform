# terraform {
#   required_providers {
#     aws = {
#         source = "hashicorp/aws"
#         version = "4.18.0"
#     }
#   }
# }


variable "test_access_key" {
  description = "test_access_key"
  type = string
  default = ""
}

variable "test_secrete_key2" {
  description = "test_secrete_key"
  type = string
  default = ""

}
variable "test_region" {
  description = "value"
  type = map
  default = {
      ap-south-01 = "ap-south-1"
      ap-north-01 = "ap-north-1"
  }

}

provider "aws" {
  access_key = var.test_access_key
  secret_key = var.test_secrete_key
  region = "${var.test_region.ap-south-01}"
}

#------------------------------------------------------------------------




variable "test_cidr" {
  default = "10.0.0.0/16"
}


variable "subnet1_cidr" {
  default = "10.0.1.0/24"
}


variable "subnet2_cidr" {
  default = "10.0.2.0/24"
}


resource "aws_vpc" "test_vpc_1" {
  cidr_block = var.test_cidr
  instance_tenancy = "default"

  tags = {
    "Name" = "test_vpc_1"
  }
}


resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc_1.id
}

resource "aws_route_table" "test_route" {
  vpc_id = aws_vpc.test_vpc_1.id

  route {
      cidr_block= "10.0.0.1/24"
      gateway_id= aws_internet_gateway.test_igw.id
  }
  
}

#------------------------------------------------------------------------------------

resource "aws_subnet" "public_subnet_01" {
  
  vpc_id = aws_vpc.test_vpc_1.id
  cidr_block = var.subnet1_cidr

  tags = {
    "Name" = "public_subnet_01"
  }
}

resource "aws_subnet" "private_subnet_01" {
  vpc_id = aws_vpc.test_vpc_1.id
  cidr_block = var.subnet2_cidr

  tags = {
    "Name" = "public_subnet_01"
  }
}



resource "aws_route_table_association" "test_rt_assoc" {
  route_table_id = aws_route_table.test_route.id

  subnet_id = aws_subnet.public_subnet_01.id
}


#--------------------------------------------------------------------------------

variable "ports" {
  default = [3600, 22,80,443, 8080]
}

resource "aws_security_group" "test_sg_allow" {

    # ingress = [ {
    #   cidr_blocks = [aws_vpc.test_vpc_1.cidr_block]
    #   description = "allowed ports for ingress traffic"
    #   from_port = 8080
    #   to_port = 8080
    #   protocol = "tcp" 
    # } ]

description="test_sg"
vpc_id  = aws_vpc.test_vpc_1.id

dynamic "ingress"{

  for_each = var.ports
  iterator = port

  content{
      cidr_blocks = [aws_vpc.test_vpc_1.cidr_block]
      description = "allowed ports for ingress traffic"
      from_port = port.value
      to_port = port.value
      protocol = "tcp" 
  }

}

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  
}