variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "cloudtrail_log_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for CloudTrail logs if this design is ever applied."
  default     = "replace-me-enterprise-secure-k8s-cloudtrail"
}
