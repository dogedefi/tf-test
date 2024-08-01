output "memoo_bucket" {
  description = "the created S3 bucket"
  value       = aws_s3_bucket.memoo_app_dev
}

output "memoo_bucket_id" {
  description = "id of the created S3 bucket"
  value       = aws_s3_bucket.memoo_app_dev.id
}
