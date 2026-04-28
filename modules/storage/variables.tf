# --- Global Environment Variables ---

variable "environment_type" {
  description = "The type of the environment used for resource naming"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment used for resource naming"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID to ensure S3 bucket name uniqueness"
  type        = string
}

variable "common_tags" {
  description = "A map of common tags for storage resources"
  type        = map(string)
}