# --- Global Environment Variables ---

variable "environment_type" {
  description = "The type of the environment used for resource naming"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment used for resource naming"
  type        = string
}

variable "aws_region" {
  description = "The AWS region for the service endpoints"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where endpoints will be provisioned"
  type        = string
}

variable "private_route_table_id" {
  description = "Route table ID for the Private subnet to associate the S3 Gateway"
  type        = string
}

variable "isolated_route_table_id" {
  description = "Route table ID for the Isolated subnet to associate the S3 Gateway"
  type        = string
}

variable "isolated_subnet_id" {
  description = "The subnet ID where the Interface Endpoint ENI will be placed"
  type        = string
}

variable "endpoint_sg_id" {
  description = "The Security Group ID to control traffic to the interface endpoint"
  type        = string
}

variable "common_tags" {
  description = "A map of common tags for endpoint resources"
  type        = map(string)
}