output "trail_arn" {
  value = aws_cloudtrail.this.arn
}

output "log_bucket_name" {
  value = aws_s3_bucket.logs.id
}
