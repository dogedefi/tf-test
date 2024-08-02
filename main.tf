# Create an S3 bucket for hosting the website
module "s3" {
  source = "./modules/s3"
}

# Create a CloudFront distribution for the memoo
module "cdn" {
  source = "./modules/cdn"
}

# Create a Route 53 record for the website
