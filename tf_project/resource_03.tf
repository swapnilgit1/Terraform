resource "aws_s3_bucket" "my_buck" {

  bucket = "terra_test_aws_my_bucket_01"

  tags = {
    Name = "My bucket"
  }

}


resource "aws_s3_bucket_versioning" "s3_ver" {
  bucket = aws_s3_bucket.my_buck.id
  versioning_configuration {
    status = "Enabled"
  }
}