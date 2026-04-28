# --- Global Environment Variables ---

variable "environment_type" {
  description = "The type of the environment used for resource naming"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment used for resource naming"
  type        = string
}

variable "private_subnet_id" {
  description = "Subnet ID for the public-facing Lambda"
  type        = string
}

variable "isolated_subnet_id" {
  description = "Subnet ID for the isolated processor Lambda"
  type        = string
}

variable "public_lambda_sg_id" {
  description = "Security Group ID for the public-facing Lambda"
  type        = string
}

variable "isolated_lambda_sg_id" {
  description = "Security Group ID for the isolated processor Lambda"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for IAM policy permissions"
  type        = string
}

variable "common_tags" {
  description = "A map of common tags for compute resources"
  type        = map(string)
}