output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "guardduty_detector_id" {
  value = module.guardduty.detector_id
}

output "cloudtrail_bucket_name" {
  value = module.cloudtrail.log_bucket_name
}

output "waf_web_acl_arn" {
  value = module.waf.web_acl_arn
}
