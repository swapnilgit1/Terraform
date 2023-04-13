

resource "aws_instance" "ec2_test" {

  ami           = var.my_ami
  instance_type = var.ec2_type
  key_name      = var.my_key

  tags = {
    "Name"  = "test_server_01"
    "Owner" = "swapnil"
  }

}


