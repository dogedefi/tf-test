data "aws_s3_bucket" "memoo_app_dev" {
  bucket = "memoo-app-dev"
}

resource "aws_cloudfront_distribution" "memoo_app_dev_distribution" {
  origin {
    domain_name = data.aws_s3_bucket.memoo_app_dev.bucket_regional_domain_name
    origin_id   = "memoo-app-dev-s3-origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "memoo-app-dev-s3-origin"

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
    compress               = true
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:ap-southeast-2:767397808373:certificate/62044f6c-cce2-4af2-9f1a-54c78034bc5a"
    ssl_support_method  = "sni-only"
  }
}
