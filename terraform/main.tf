provider "aws" {
  region = var.aws_region
}

# Create a buclet to store system stuff.
resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket
  acl    = "private"

  tags = {
    Name        = var.s3_bucket
    Environment = "Dev"
  }
}
