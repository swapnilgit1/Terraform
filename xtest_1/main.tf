
variable "myregion" {
  default = "ap-south-1"
  type    = string
}

variable "myami" {
  default = "ami-0cfedf42e63bba657"
  type    = string
}




provider "aws" {
  access_key = ""
  secret_key = ""
  region     = var.myregion
}



 #-----------------------------------------------------------------------------------


resource "aws_instance" "ec2_test" {
  ami           = var.myami
  key_name      = "LAMP1"
  instance_type = "t2.micro"
   
  tags = {
    "Name" = "vm_test_01"
  }

  ebs_block_device {
    encrypted   = true
    volume_size = "80"
    iops        = "1000"
    device_name = "my_ebs"
    volume_type = "io1"
    delete_on_termination = true
    throughput = "900"
  }

  hibernation = true
  monitoring = true
  availability_zone = "ap-south-1a"
  placement_group = "dedicated"
  iam_instance_profile = "ec2fullaccess"


  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }


}

resource "aws_efs_mount_target" "my_efs" {
  ip_address = aws_instance.ec2_test.private_ip
  subnet_id = aws_instance.ec2_test.subnet_id
  file_system_id = "234243451fwf234"



}

  #-----------------------------------------------------------------------------------




resource "aws_s3_bucket" "server1_bucket" {
  bucket = "swapnil_test01_testinfra_bucket"
}

resource "aws_s3_bucket_versioning" "versioning_s3" {
 bucket = aws_s3_bucket.server1_bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}


#----------------------------------------------------------------------------------------



output "ip" {
  value = aws_instance.ec2_test.public_ip
}

output "id" {
  value = aws_instance.ec2_test.id
}

output "id1" {
  value = aws_instance.ec2_test.availability_zone
}


output "s3_ver" {
  value = aws_s3_bucket_versioning.versioning_s3.versioning_configuration
}

output "az" {
  value = aws_instance.ec2_test.availability_zone
}


output "efs" {
  value = aws_efs_mount_target.my_efs.file_system_id
}