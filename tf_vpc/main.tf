


provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "ap-south-1"
}



#---------------------------------------------------------------------------


resource "aws_vpc" "terra_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    "Name" = "terra_vpc"
  }
}


resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terra_vpc.id

  tags = {
    "Name" = "terra_igw"
  }
}


resource "aws_route_table" "terra_rout" {
  vpc_id = aws_vpc.terra_vpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.terra_igw.id
  }

}


#---------------------------------------------------------------------------------------------




resource "aws_subnet" "public_subnet_1" {

  vpc_id     = aws_vpc.terra_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    "Name" = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {

  vpc_id     = aws_vpc.terra_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    "Name" = "public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_1" {

  vpc_id     = aws_vpc.terra_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    "Name" = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {

  vpc_id     = aws_vpc.terra_vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    "Name" = "private_subnet_2"
  }
}



#---------------------------------------------------------------------------------


resource "aws_route_table_association" "rt_asso_1" {
  route_table_id = aws_route_table.terra_rout.id

  subnet_id = aws_subnet.public_subnet_1.id

}
resource "aws_route_table_association" "rt_asso_2" {
  route_table_id = aws_route_table.terra_rout.id

  subnet_id = aws_subnet.public_subnet_2.id

}







#-----------------------------------------------------------------------------------------

variable "ports" {
  default = [22, 80, 443, 3306, 8080]
}

resource "aws_security_group" "allow_rule" {

  name        = "allowed traffic"
  description = "i/b rule"
  vpc_id      = aws_vpc.terra_vpc.id

  dynamic "ingress" {

    for_each = var.ports
    iterator = port

    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = [aws_vpc.terra_vpc.cidr_block]

    }
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allowed_traffic"
  }
}




#------------------------------------------------------------------

output "sg" {
  value = aws_security_group.allow_rule.ingress
}

