output "public_lambda_arn" {
  value = aws_lambda_function.public.arn
}

output "isolated_lambda_arn" {
  value = aws_lambda_function.isolated.arn
}