output "public_lambda_sg_id" {
  value = aws_security_group.public_lambda_sg.id
}

output "isolated_lambda_sg_id" {
  value = aws_security_group.isolated_lambda_sg.id
}

output "waf_acl_arn" {
  value = aws_wafv2_web_acl.main.arn
}