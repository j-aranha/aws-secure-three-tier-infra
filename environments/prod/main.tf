# --- Terraform Configuration & Backend ---
terraform {
  required_version = ">= 1.5.0"

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# --- Provider Configuration ---
provider "aws" {
  region = var.aws_region
}

# --- 1. Network Layer ---
module "network" {
  source               = "../../modules/network"
  environment_type     = var.environment_type
  environment_name     = var.environment_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = "10.0.1.0/24"
  private_subnet_cidr  = "10.0.2.0/24"
  isolated_subnet_cidr = "10.0.3.0/24"
  common_tags          = local.common_tags
}

# --- 2. Security Layer (WAF & Security Groups) ---
module "security" {
  source                = "../../modules/security"
  environment_type      = var.environment_type
  environment_name      = var.environment_name
  api_gateway_stage_arn = module.api_gateway.public_api_stage_arn
  vpc_id                = module.network.vpc_id
  vpc_cidr              = var.vpc_cidr
  common_tags           = local.common_tags
}

# --- 3. Storage Layer (Encrypted S3) ---
module "storage" {
  source           = "../../modules/storage"
  environment_type = var.environment_type
  environment_name = var.environment_name
  account_id       = data.aws_caller_identity.current.account_id
  common_tags      = local.common_tags
}

# --- 4. Endpoints Layer (VPC Endpoints for S3 and API GW) ---
module "endpoints" {
  source                  = "../../modules/endpoints"
  environment_type        = var.environment_type
  environment_name        = var.environment_name
  aws_region              = var.aws_region
  vpc_id                  = module.network.vpc_id
  private_route_table_id  = module.network.private_route_table_id
  isolated_route_table_id = module.network.isolated_route_table_id
  isolated_subnet_id      = module.network.isolated_subnet_id
  # Senior touch: using a specific SG for endpoints if available, 
  # or reusing the security module output
  endpoint_sg_id = module.security.isolated_lambda_sg_id
  common_tags    = local.common_tags
}

# --- 5. API Gateway Layer (Public & Private) ---
module "api_gateway" {
  # Corrigido o nome da pasta para bater com o seu 'terraform init' se necessário
  source           = "../../modules/api-gateway"
  environment_type = var.environment_type
  environment_name = var.environment_name
  vpc_id           = module.network.vpc_id
  vpc_endpoint_id  = module.endpoints.api_gw_endpoint_id
  common_tags      = local.common_tags
}

# --- 6. Compute Layer (Lambdas & IAM) ---
module "compute" {
  source                = "../../modules/compute"
  environment_type      = var.environment_type
  environment_name      = var.environment_name
  private_subnet_id     = module.network.private_subnet_id
  isolated_subnet_id    = module.network.isolated_subnet_id
  public_lambda_sg_id   = module.security.public_lambda_sg_id
  isolated_lambda_sg_id = module.security.isolated_lambda_sg_id
  s3_bucket_arn         = module.storage.s3_bucket_arn
  common_tags           = local.common_tags
}