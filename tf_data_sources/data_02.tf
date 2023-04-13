
data "aws_key_pair" "data_key" {

  key_pair_id = "key-0cefac3655f94837e"
  key_name    = "LAMP1"

  filter {
    name   = "fingerprint"
    values = ["${var.data_key}"]
  }
  
}