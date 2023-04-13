
variable "my_region" {
  type= string
  default = {
    region1 = "ap-south-1"
    region2 = "us-east-1"
  }
  description = "this is region for aws ec2"
}

variable "my_key_name" {
  type= string
  default= "key1"
}

variable "my_ami" {
  type="string"
  default = {
    ami1 = "tyu1312323"
    ami2 = "2456564543"
  }
}


provider "aws" {
  access_key = ""
  secret_key = ""
  region = var.my_key_name.region1
}


resource "aws_instance" "test_ec2" {
  ami = var.my_ami.ami1
  key_name = var.my_key_name
  instance_type = "t2.micro"

  tags = {
    "Name" = "abc"
    "Owner" = "xyz"
  }

  hibernation = true
  placement_group = "dedicated"
  monitoring = true    
  availability_zone = "ap-south-1a"

  ebs_block_device {
    volume_size = 20
    volume_type = "io1"
    iops = "3000"
    encrypted = false   
    
    }
}



output "ec2_id" {
  value = "${aws_instance.test_ec2_[0].id}"
}








