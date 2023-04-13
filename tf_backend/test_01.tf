terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.18.0"
    }
  }
}


provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "ap-south-1"
}


variable "ec2_ami" {
  description = "ami to be used in diff az"
  type = map(any) 

  default = {
    ap-south-1 = "ami-0cfedf42e63bba657"
    ap-south-2 = "ami-0cfedf42e63bba658"
  }
}

variable "tag" {
    description = "tags for ec2"
  type = map(any)
  default = {
    Name  = "my_test_"
    Owner = "swapnil"
  }
}



resource "aws_instance" "test_ec2" {

  count         = 2
  instance_type = "t2.micro"

  ami = "${var.ec2_ami.ap-south-1}"
  key_name      = "LAMP1"


  tags = {
    "Name"  = "${var.tag.Name}_${count.index}"
    "Owner" = "${var.tag.Owner}"
  }

  vpc_security_group_ids = [ "value" ]
  user_data = ""
  provisioner "file" {}

  

}


resource "aws_instance" "prod_ec2" {

  instance_type = "t2.large"
  ami = "${var.ec2_ami.ap-south-2}"
  key_name      = "LAMP1"

  tags = var.tag
}


output "ami" {
  value =  aws_instance.prod_ec2.ami
  
}