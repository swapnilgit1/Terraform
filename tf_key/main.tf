provider "aws" {
  access_key = var.myaccess_key
  secret_key = var.mysecrete_key
  region     = var.myregion
}


resource "aws_key_pair" "deployer_key" {                     # key
  key_name = "key_tf"
  public_key = file("${path.module}/key_rsa.pub")
}




resource "aws_instance" "ec2_key_test" {
  ami           = var.my_ami                                 # instance ec2
  instance_type = var.ec2_type

  key_name = aws_key_pair.deployer_key.key_name

  tags = {
    "Name"  = "test_server_01"
    "Owner" = "swapnil"
  }

}



output "ec2_ip" {
  value = aws_instance.ec2_key_test.public_ip
}

output "ec2_id" {
  value = aws_instance.ec2_key_test.id
}

output "ec2_type" {
  value = aws_instance.ec2_key_test.instance_type
}

output "key_name" {
  value = aws_key_pair.deployer_key.key_name
}


#-----------------------------------------------------------------------------------------------

# PROCEDURE_

# 1. generate key pair using command "> ssh-keygen -t rsa" on GIT Console
# 2. generate in pwd , will ask for key location give "./<key_name>"
# 3. two keys public/private will be generated 

# 4. follow code to assign key to instance

# 5. HOW TO SSH IN TO instance
#    1. after writing iac code, create infra and check if correct key is assigned to instance.
#    2. if SG is not specified in code, default sg will be assigned.
#    3. rules of default sg will not allow ssh in to ec2.
  
#    4. create new sg or edit the rule of existing one.
#       a. add inbound rule to sg with all traffic allowed (0.0.0.0/0) and souce as custome ipv4 
#       b. add outbound rule to sg with all traffic allowed (0.0.0.0/0) and souce as custome ipv4
#       c. assign the SG to EC2 from ec2 dashboard Action button.

# 6. SSH in to your instance using command _ 
#     > ssh -i <private_key_name> <user_name>@<public_ip> , at dir where we created key using ssh_keygen.

#     eg. $ ssh -i key_rsa ubuntu@35.154.201.108



