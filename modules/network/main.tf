data "aws_availability_zones" "available" {}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, { Name = "${var.environment_type}-${var.environment_name}-vpc" })
}

# Subnets
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags              = merge(var.common_tags, { Name = "public-subnet" })
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags              = merge(var.common_tags, { Name = "private-egress-subnet" })
}

resource "aws_subnet" "isolated" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.isolated_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags              = merge(var.common_tags, { Name = "isolated-subnet" })
}

# Gateway & NAT
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.common_tags, { Name = "igw" })
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(var.common_tags, { Name = "nat-eip" })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags          = merge(var.common_tags, { Name = "nat-gateway" })
}

# --- Routing Logic ---

# Public: Rota para IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private: Rota para NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Isolated: Sem rota externa (Apenas Local)
resource "aws_route_table" "isolated" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table_association" "isolated" {
  subnet_id      = aws_subnet.isolated.id
  route_table_id = aws_route_table.isolated.id
}