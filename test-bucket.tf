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
    "bucket_object_upload.JPG" = "image/jpg"
  }
}

resource "aws_s3_object" "submission_evidence" {
  for_each = local.g-check_evidence

  bucket       = aws_s3_bucket.frontend.id
  key          = each.key
  source       = "${path.module}/g-check_evidence/${each.key}"
  content_type = each.value
  source_hash  = filemd5("${path.module}/g-check_evidence/${each.key}")
}

resource "aws_s3_bucket" "frontend" {
  bucket_prefix = "jenkins-bucket-"
  force_destroy = true
  

  tags = {
    Name = "Jenkins Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "assets_access" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "assets_read_policy" {
  depends_on = [aws_s3_bucket_public_access_block.assets_access]
  bucket     = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::YOUR_BUCKET/*"
      }
    ]
  })
}