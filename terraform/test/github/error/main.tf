resource "aws_s3_bucket" "my_bucket" {
  bucket="hello"
}

provider "aws" {
  region = "eu-west-1"
}
