data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment_name}-vpc"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.environment_name}-igw"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = var.public_subnet_1_cidr
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment_name}-public-subnet-1"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
    Tier        = "public"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = var.public_subnet_2_cidr
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment_name}-public-subnet-2"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
    Tier        = "public"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = var.private_subnet_1_cidr
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment_name}-private-subnet-1"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
    Tier        = "private"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = var.private_subnet_2_cidr
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment_name}-private-subnet-2"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
    Tier        = "private"
  }
}

resource "aws_eip" "nat_1" {
  domain = "vpc"

  tags = {
    Name        = "${var.environment_name}-nat-eip-1"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_eip" "nat_2" {
  domain = "vpc"

  tags = {
    Name        = "${var.environment_name}-nat-eip-2"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name        = "${var.environment_name}-nat-1"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name        = "${var.environment_name}-nat-2"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.environment_name}-public-routes"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.environment_name}-private-routes-1"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_route" "private_1_default" {
  route_table_id         = aws_route_table.private_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.environment_name}-private-routes-2"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_route" "private_2_default" {
  route_table_id         = aws_route_table.private_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_2.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}