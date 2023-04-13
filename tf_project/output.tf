output "ec2_ip" {
  value = aws_instance.ec2_test.public_ip
}

output "ec2_id" {
  value = aws_instance.ec2_test.id
}

output "ec2_type" {
  value = aws_instance.ec2_test.instance_type
}


output "owner" {
  value = aws_instance.ec2_test.tags_all
}


output "sg" {
  value = aws_security_group.mysg1.id
}


