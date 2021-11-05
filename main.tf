terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
  required_version = "~> 1.0"
  backend "s3" {
    ### !!! STATE BUCKET !!! ###
    bucket = "hymnharmonia"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}

# Credentials and region go here
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

}
