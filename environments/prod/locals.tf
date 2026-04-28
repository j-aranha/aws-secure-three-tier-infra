locals {
  common_tags = {
    Project         = "aws-secure-three-tier-infra"
    EnvironmentType = var.environment_type
    EnvironmentName = var.environment_name
    ManagedBy       = "Terraform"
    Owner           = "j-aranha"
  }
}

data "aws_caller_identity" "current" {}