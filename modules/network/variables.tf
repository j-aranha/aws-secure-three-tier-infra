# --- Global Environment Variables ---

variable "environment_type" {
  description = "The type of the environment used for resource naming"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment used for resource naming"
  type        = string
}

variable "common_tags" {
  description = "A map of common tags to be applied to all networking resources"
  type        = map(string)
}

# --- VPC & Subnet Networking Variables ---

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the Public Subnet (hosting the NAT Gateway)"
  type        = string
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the Private Subnet (Lambda with Egress access)"
  type        = string
}

variable "isolated_subnet_cidr" {
  description = "The CIDR block for the Isolated Subnet (Truly isolated processing)"
  type        = string
}