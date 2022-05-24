
output "ec2_id" {
  value = aws_instance.ec2_test.id
}

output "ec2_type" {
  value = aws_instance.ec2_test.instance_type
}



output "data_ami" {
  value = data.aws_ami.my_ami.id
}

output "data_key" {
  value = data.aws_key_pair.data_key.key_name
}