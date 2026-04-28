# modules/security/main.tf

# 1. Security Group for the Public-Facing Lambda
resource "aws_security_group" "public_lambda_sg" {
  name        = "${var.environment_type}-${var.environment_name}-public-lambda-sg"
  description = "Security group for the public-facing lambda function"
  vpc_id      = var.vpc_id

  # Egress: Allow outbound traffic to the internet via NAT Gateway (Required for external APIs)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "public-lambda-sg" })
}

# 2. Security Group for the Isolated Lambda
resource "aws_security_group" "isolated_lambda_sg" {
  name        = "${var.environment_type}-${var.environment_name}-isolated-lambda-sg"
  description = "Restricts traffic to internal sources only"
  vpc_id      = var.vpc_id

  # Ingress: Only allow HTTPS traffic coming from the Public Lambda Security Group
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.public_lambda_sg.id]
  }

  # Egress: Strictly limited to the VPC internal range for Endpoint communication
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(var.common_tags, { Name = "isolated-lambda-sg" })
}

# 3. Security Group for VPC Endpoints (Interface Endpoints)
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.environment_type}-${var.environment_name}-vpc-endpoint-sg"
  description = "Controls access to VPC Interface Endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    # Only allow the Isolated Lambda to call the Private API via this Endpoint
    security_groups = [aws_security_group.isolated_lambda_sg.id]
  }

  tags = merge(var.common_tags, { Name = "vpc-endpoint-sg" })
}

# 4. AWS WAFv2 Web ACL
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.environment_type}-${var.environment_name}-api-waf"
  description = "Regional WAF to protect the public API endpoint"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Managed Rule: Amazon IP Reputation List (Blocks known malicious IPs)
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WAF-IP-Reputation"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAF-Main-ACL"
    sampled_requests_enabled   = true
  }
}

# 5. WAF ASSOCIATION
# This links the WAF to the Public API Stage
resource "aws_wafv2_web_acl_association" "api_main" {
  resource_arn = var.api_gateway_stage_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}