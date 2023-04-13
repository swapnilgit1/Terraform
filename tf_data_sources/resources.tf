

resource "aws_instance" "ec2_test" {

  ami           = data.aws_ami.my_ami.id
  key_name      = data.aws_key_pair.data_key.key_name
  instance_type = var.ec2_type
  
 # key_name = "LAMP1"

  tags = {
    "Name"  = "test_server_01"
    "Owner" = "swapnil"
  }

}


