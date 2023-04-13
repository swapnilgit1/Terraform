
variable "tags" {
  type = map
  default = {Name="ec2", Owner="swapnil"}
}


variable "name" {
  type = string
  default = "EC2_0"

}


resource "aws_instance" "vpc_ec2" {
  count = 3
  instance_type = "t2.micro"
  ami           = "ami-0cfedf42e63bba657"
  key_name      = "LAMP1"


  tags = var.tags





  depends_on = [
    aws_vpc.terra_vpc
  ]

  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = ["aws_security_group.allow_rule.id"]

}


# output "sg_id" {
#   value = aws_instance.vpc_ec2.security_groups
# }
