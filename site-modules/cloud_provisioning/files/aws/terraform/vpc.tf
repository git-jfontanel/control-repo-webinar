
resource "aws_vpc" "core-vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(
    local.common_tags,
    tomap(
      { "Name" = "${var.name}-${var.region}-vpc" }
    )
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.core-vpc.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.name}-${var.region}-igw" }
    )
  )
}

resource "aws_route_table" "to-igw" {
  vpc_id = aws_vpc.core-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.name}-${var.region}-route-to-igw" })
  )
}

resource "aws_subnet" "core-subnet" {
  vpc_id                  = aws_vpc.core-vpc.id
  cidr_block              = "10.10.0.0/24"
  depends_on              = [aws_internet_gateway.gw]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name}-subnet-az}"
    },
  )
}

resource "aws_route_table_association" "core" {
  subnet_id      = aws_subnet.core-subnet.id
  route_table_id = aws_route_table.to-igw.id
}