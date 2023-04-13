

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
}


resource "aws_key_pair" "key_pub" {
  key_name = tls_private_key.my_key.id
  public_key = tls_private_key.my_key.public_key_openssh
}


resource "local_file" "key_private" {
  content =tls_private_key.my_key.private_key_openssh
  filename = "ec2_key.pem"
}