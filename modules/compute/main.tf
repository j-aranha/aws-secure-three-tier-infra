# --- ARCHIVE STRATEGY ---
# This generates a dummy zip file on-the-fly, ensuring the infrastructure
# can be validated and planned without external binary dependencies.
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/dummy_lambda.zip"

  source {
    content  = "// placeholder code for infrastructure validation"
    filename = "index.js"
  }
}

# --- IAM ROLE ---
resource "aws_iam_role" "lambda_exec" {
  name = "${var.environment_type}-${var.environment_name}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

# Attach VPC Access Policy (Standard for Lambdas in VPC)
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

  tags = var.common_tags
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

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [var.public_lambda_sg_id]
  }

  tags = merge(var.common_tags, { Name = "${var.environment_type}-${var.environment_name}-public-lambda" })
}

# --- 2. ISOLATED PROCESSOR LAMBDA ---
resource "aws_lambda_function" "isolated" {
  function_name = "${var.environment_type}-${var.environment_name}-isolated-processor"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [var.isolated_subnet_id]
    security_group_ids = [var.isolated_lambda_sg_id]
  }

  tags = merge(var.common_tags, { Name = "${var.environment_type}-${var.environment_name}-isolated-lambda" })
}

# --- 3. LAMBDA PERMISSIONS ---

# Allows the Public API Gateway to invoke the Public Lambda
resource "aws_lambda_permission" "allow_public_api" {
  statement_id  = "AllowExecutionFromPublicAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.public.function_name
  principal     = "apigateway.amazonaws.com"
}

# Allows the Private API Gateway to invoke the Isolated Lambda
resource "aws_lambda_permission" "allow_private_api" {
  statement_id  = "AllowExecutionFromPrivateAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.isolated.function_name
  principal     = "apigateway.amazonaws.com"
}