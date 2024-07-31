# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-2"
}

# Create an S3 bucket for hosting the website
resource "aws_s3_bucket" "memoo" {
  bucket = "memoo-app-dev"
}

resource "aws_s3_bucket_website_configuration" "memoo" {
  bucket = aws_s3_bucket.memoo.id

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

resource "aws_s3_bucket_ownership_controls" "memoo" {
  bucket = aws_s3_bucket.memoo.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "memoo" {
  bucket = aws_s3_bucket.memoo.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "memoo" {
  depends_on = [
    aws_s3_bucket_ownership_controls.memoo,
    aws_s3_bucket_public_access_block.memoo,
  ]

  bucket = aws_s3_bucket.memoo.id
  acl    = "public-read"
}

# Create a CloudFront distribution for the memoo
resource "aws_cloudfront_distribution" "memoo_distribution" {
  origin {
    domain_name = aws_s3_bucket.memoo.website_endpoint
    origin_id   = "memoo-origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "memoo-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "development"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# # Create a Route 53 record for the website
# resource "aws_route53_zone" "website_zone" {
#   name = "your-domain.com"
# }

# resource "aws_route53_record" "website_record" {
#   zone_id = aws_route53_zone.website_zone.id
#   name    = "your-domain.com"
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.website_distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# }
