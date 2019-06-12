resource "aws_s3_bucket" "test" {
  bucket = "test"
}

provider "aws" {
  region = "eu-west-1"
}
