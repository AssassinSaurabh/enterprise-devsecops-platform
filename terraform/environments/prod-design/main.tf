terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name = "enterprise-secure-k8s"
  tags = {
    Project     = "enterprise-devsecops-platform"
    Environment = "prod-design"
    ManagedBy   = "terraform"
    CostMode    = "design-only"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name       = local.name
  cidr_block = "10.40.0.0/16"

  public_subnets = {
    a = {
      cidr_block        = "10.40.0.0/20"
      availability_zone = "${var.aws_region}a"
    }
    b = {
      cidr_block        = "10.40.16.0/20"
      availability_zone = "${var.aws_region}b"
    }
  }

  private_subnets = {
    a = {
      cidr_block        = "10.40.64.0/20"
      availability_zone = "${var.aws_region}a"
    }
    b = {
      cidr_block        = "10.40.80.0/20"
      availability_zone = "${var.aws_region}b"
    }
  }

  tags = local.tags
}

module "eks" {
  source = "../../modules/eks"

  name                   = local.name
  kubernetes_version     = "1.30"
  subnet_ids             = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_subnet_ids        = module.vpc.private_subnet_ids
  enable_public_endpoint = false
  tags                   = local.tags
}

module "guardduty" {
  source = "../../modules/guardduty"

  tags = local.tags
}

module "security_hub" {
  source = "../../modules/security-hub"

  enabled_standards = [
    "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0",
    "arn:aws:securityhub:${var.aws_region}::standards/cis-aws-foundations-benchmark/v/1.4.0"
  ]
}

module "cloudtrail" {
  source = "../../modules/cloudtrail"

  name            = "${local.name}-trail"
  log_bucket_name = var.cloudtrail_log_bucket_name
  tags            = local.tags
}

module "waf" {
  source = "../../modules/waf"

  name = "${local.name}-waf"
  tags = local.tags
}
