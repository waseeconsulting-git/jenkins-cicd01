terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Use latest version if possible
    }
  }

  backend "s3" {
    bucket  = "terraform-state-van"                 # Name of the S3 bucket
    key     = "jenkins-test-020220.tfstate"        # The name of the state file in the bucket
    region  = "us-east-1"                          # Use a variable for the region
    encrypt = true                                 # Enable server-side encryption (optional but recommended)
  } 
}

provider "aws" {
  region  = "us-east-1"
}

locals {
  g-check_evidence = {
    "armageddon.txt"                     = "text/plain"
    "Destroy-complete.JPG"              = "image/jpg"
    "Apply-complete.JPG"            = "image/jpg"
    "SUCCESS.JPG"             = "image/jpg"
    "webhook-delivery.JPG"          = "image/jpg"
    "u6KxR-1W.jpg" = "image/jpg"
    "wub8Qfph.jpg" = "image/jpg"
  }
}

resource "aws_s3_object" "submission_evidence" {
  for_each = local.g-check_evidence

  bucket       = aws_s3_bucket.frontend.id
  key          = each.key
  source       = "${path.module}/evidence/${each.key}"
  content_type = each.value
  source_hash  = filemd5("${path.module}/evidence/${each.key}")
}

resource "aws_s3_bucket" "frontend" {
  bucket_prefix = "jenkins-bucket-"
  force_destroy = true
  

  tags = {
    Name = "Jenkins Bucket"
  }
}