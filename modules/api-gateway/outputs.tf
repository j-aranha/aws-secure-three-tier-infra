output "public_api_url" {
  value = aws_apigatewayv2_stage.public.invoke_url
}

output "private_api_id" {
  value = aws_api_gateway_rest_api.private.id
}

output "public_api_stage_arn" {
  value = aws_apigatewayv2_stage.public.arn
}