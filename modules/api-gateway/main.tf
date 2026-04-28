# --- PUBLIC API GATEWAY ---
resource "aws_apigatewayv2_api" "public" {
  name          = "${var.environment_type}-${var.environment_name}-public-api"
  protocol_type = "HTTP"
  tags          = var.common_tags
}

resource "aws_apigatewayv2_stage" "public" {
  api_id      = aws_apigatewayv2_api.public.id
  name        = "$default"
  auto_deploy = true
}

# --- PRIVATE API GATEWAY (REST API for strict Access Control) ---
resource "aws_api_gateway_rest_api" "private" {
  name        = "${var.environment_type}-${var.environment_name}-private-api"
  description = "Isolated API for sensitive data processing"

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [var.vpc_endpoint_id]
  }
}

# Resource Policy: Only allow traffic from our VPC
resource "aws_api_gateway_rest_api_policy" "private_policy" {
  rest_api_id = aws_api_gateway_rest_api.private.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "${aws_api_gateway_rest_api.private.execution_arn}/*"
        Condition = {
          StringNotEquals = {
            "aws:SourceVpc" = var.vpc_id
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "${aws_api_gateway_rest_api.private.execution_arn}/*"
      }
    ]
  })
}