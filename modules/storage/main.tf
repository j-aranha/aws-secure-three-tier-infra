# modules/storage/main.tf

# 1. S3 Bucket for sensitive data storage
resource "aws_s3_bucket" "sensitive_data" {
  bucket = "${var.environment_type}-${var.environment_name}-data-${var.account_id}" 

  # Safeguard to prevent accidental deletion of sensitive data
  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.common_tags, { Name = "sensitive-data-storage" })
}

# 2. Server-Side Encryption (Requirement: AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.sensitive_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 3. Public Access Block (Strict Security Best Practice)
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.sensitive_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}