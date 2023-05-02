resource "random_string" "deploy-bucketname-suffix" {
  special = false
  length  = 6
  lower   = true
  upper   = false
}
resource "aws_s3_bucket" "custom-s3-deploy-bucket" {
  bucket = "custom-s3-bucket-${random_string.deploy-bucketname-suffix.result}"

  tags = {
    Name = "S3 Deploy bucket - ${random_string.deploy-bucketname-suffix.result}"
  }
}