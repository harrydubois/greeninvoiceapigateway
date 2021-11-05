# Input variable definitions
variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  default     = "CHANGEME"
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  default     = "CHANGEME"
}

variable "lambda_bucket_prefix" {
  description = "Prefix for the randomly generated S3 Lambda Code bucket name"
  type = string
  default = "lambda-bucket"
}

variable "message_bucket_prefix" {
  description = "Prefix for the randomly generated SQS message S3 bucket name"
  type = string
  default = "message-bucket"
}

variable "domain_name" {
  description = "Domain name to use for API Gateway"
  type = string
  default = "change.me"
}

variable "api_gateway_name" {
  description = "Name of the API Gateway resource"
  type = string
  default = "green_invoice_lambda"
}

variable "hosted_zone" {
  description = "Hosted zone in Route 53 - usually apex domain"
  type = string
  default = "change.me"
}

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-west-1"
}
