output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "isolated_subnet_id" {
  value = aws_subnet.isolated.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "isolated_route_table_id" {
  value = aws_route_table.isolated.id
}