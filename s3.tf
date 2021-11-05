### Randomly generate bucket names
resource "random_pet" "lambda_bucket_name" {
  prefix = var.lambda_bucket_prefix
  length = 4
}
resource "random_pet" "message_bucket_name" {
  prefix = var.message_bucket_prefix
  length = 4
}

### Create buckets to store lambda code and SQS messages in
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id

  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "message_bucket" {
  bucket = random_pet.message_bucket_name.id

  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "alias/greendev/terraform/s3"
        sse_algorithm = "aws:kms"
      }
    }
  }
}

### Archive code files in .zip
data "archive_file" "api_to_sqs" {
  type = "zip"

  source_dir  = "${path.module}/lambda/api_to_sqs"
  output_path = "${path.module}/api_to_sqs.zip"
}
data "archive_file" "sqs_to_s3" {
  type = "zip"

  source_dir  = "${path.module}/lambda/sqs_to_s3"
  output_path = "${path.module}/sqs_to_s3.zip"
}

### Push those zips to our code bucket
resource "aws_s3_bucket_object" "api_to_sqs" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "api_so_sqs.zip"
  source = data.archive_file.api_to_sqs.output_path

  etag = filemd5(data.archive_file.api_to_sqs.output_path)
}
resource "aws_s3_bucket_object" "sqs_to_s3" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "sqs_to_s3.zip"
  source = data.archive_file.sqs_to_s3.output_path

  etag = filemd5(data.archive_file.sqs_to_s3.output_path)
}
