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
  description = "The ID of the VPC for the Private API resource policy"
  type        = string
}

variable "vpc_endpoint_id" {
  description = "The VPC Endpoint ID required for the Private API Gateway"
  type        = string
}

variable "common_tags" {
  description = "A map of common tags for API Gateway resources"
  type        = map(string)
}