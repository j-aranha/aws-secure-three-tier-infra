# --- Global Environment Variables ---

variable "environment_type" {
  description = "The type of the environment used for resource naming"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment used for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC for egress filtering rules"
  type        = string
}

variable "common_tags" {
  description = "A map of common tags for security resources"
  type        = map(string)
}

variable "api_gateway_stage_arn" {
  description = "The ARN of the Public API Gateway Stage required for WAF association"
  type        = string
}