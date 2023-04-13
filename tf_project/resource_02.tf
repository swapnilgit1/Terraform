

resource "aws_security_group" "mysg1" {

  name        = "my_sg_01"
  description = "Allow TLS inbound and outbound traffic"

  dynamic "ingress" {
    for_each = var.sg_ports   #for each variable
    iterator = port

    content {
      description      = "TLS from VPC"
      from_port        = port.value
      to_port          = port.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }


  egress {
    from_port        = 22
    to_port          = 22
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


}