
output "ec2_id" {
  value = aws_instance.ec2_test.id
}

output "ec2_type" {
  value = aws_instance.ec2_test.instance_type
}

