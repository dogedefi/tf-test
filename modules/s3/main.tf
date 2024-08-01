resource "aws_s3_bucket" "memoo_app_dev" {
  bucket = "memoo-app-dev"
}

resource "aws_s3_bucket_website_configuration" "memoo_app_dev" {
  bucket = aws_s3_bucket.memoo_app_dev.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

output "website_endpoint" {
  description = "URL of the created S3 static website"
  value       = aws_s3_bucket.memoo_app_dev.website_domain
}

resource "aws_s3_bucket_ownership_controls" "memoo_app_dev" {
  bucket = aws_s3_bucket.memoo_app_dev.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "memoo_app_dev" {
  bucket = aws_s3_bucket.memoo_app_dev.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "memoo_app_dev" {
  depends_on = [
    aws_s3_bucket_ownership_controls.memoo_app_dev,
    aws_s3_bucket_public_access_block.memoo_app_dev,
  ]

  bucket = aws_s3_bucket.memoo_app_dev.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "memoo_app_dev" {
  bucket = aws_s3_bucket.memoo_app_dev.id

  policy = <<POLICY
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": "*",
              "Action": "s3:GetObject",
              "Resource": "arn:aws:s3:::${aws_s3_bucket.memoo_app_dev.id}/*"
          }
      ]
  }
  POLICY
}

