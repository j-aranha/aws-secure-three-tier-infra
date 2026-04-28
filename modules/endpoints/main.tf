# modules/endpoints/main.tf

# 1. S3 Gateway Endpoint
# This allows resources in Private and Isolated subnets to access S3 buckets 
# without leaving the AWS network.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  # Associating the endpoint with the route tables of the secure subnets
  route_table_ids = [
    var.private_route_table_id, 
    var.isolated_route_table_id
  ]

  tags = merge(var.common_tags, { Name = "${var.environment_type}-${var.environment_name}-s3-gateway-endpoint" })
}

# 2. Interface Endpoint for API Gateway (execute-api)
# Required for the "Private API Gateway" to be reachable from within the VPC.
# This creates a Private IP (ENI) inside the isolated subnet.
resource "aws_vpc_endpoint" "execute_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.execute-api"
  vpc_endpoint_type   = "Interface"
  
  # Placing the endpoint interface in the isolated subnet for direct access
  subnet_ids          = [var.isolated_subnet_id]
  security_group_ids  = [var.endpoint_sg_id]
  
  # Enables private DNS so the Lambda can use the standard API Gateway URL
  private_dns_enabled = true

  tags = merge(var.common_tags, { Name = "api-gateway-interface-endpoint" })
}