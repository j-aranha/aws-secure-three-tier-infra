# Common IAM Role for Lambda VPC Execution
resource "aws_iam_role" "lambda_exec" {
  name = "${var.environment_type}-${var.environment_name}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Specific Policy for Isolated Lambda: Write only to S3
resource "aws_iam_policy" "s3_write" {
  name        = "${var.environment_type}-${var.environment_name}-lambda-s3-write"
  description = "Allows putting objects into the sensitive data bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:PutObject"
      Resource = "${var.s3_bucket_arn}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "isolated_s3" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.s3_write.arn
}

# --- 1. PUBLIC FACING LAMBDA ---
resource "aws_lambda_function" "public" {
  function_name = "${var.environment_type}-${var.environment_name}-public-service"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = "dummy_lambda.zip" # Placeholder

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [var.public_lambda_sg_id]
  }
}

# --- 2. ISOLATED PROCESSOR LAMBDA ---
resource "aws_lambda_function" "isolated" {
  function_name = "${var.environment_type}-${var.environment_name}-isolated-processor"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = "dummy_lambda.zip" # Placeholder

  vpc_config {
    subnet_ids         = [var.isolated_subnet_id]
    security_group_ids = [var.isolated_lambda_sg_id]
  }
}