# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "Webserver-Vp"
  }
}

# Create Public Subnets
resource "aws_subnet" "public_subnets" {
  count                  = length(var.public_subnet_cidr_blocks)
  vpc_id                 = aws_vpc.vpc.id
  cidr_block             = var.public_subnet_cidr_blocks[count.index]
  availability_zone      = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Sub-${aws_vpc.vpc.tags.Name}-${var.availability_zones[count.index]}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnets" {
  count                  = length(var.private_subnet_cidr_blocks)
  vpc_id                 = aws_vpc.vpc.id
  cidr_block             = var.private_subnet_cidr_blocks[count.index]
  availability_zone      = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-Sub-${aws_vpc.vpc.tags.Name}-${var.availability_zones[count.index]}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Webserver-IGW"
  }
}

# Create Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "Public-RouteTable"
  }
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_subnet_associations" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
