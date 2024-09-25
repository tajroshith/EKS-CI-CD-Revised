resource "aws_vpc" "wp-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = merge(var.common-tags, {
    "Name" = "${var.project-name}-${var.env}-wp-vpc"
  })
}

resource "aws_subnet" "wp-public-subnet" {
  vpc_id                  = aws_vpc.wp-vpc.id
  count                   = length(var.public_subnet)
  cidr_block              = element(var.public_subnet, count.index)
  availability_zone       = element(data.aws_availability_zones.azones.names, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch_public
  tags = merge(var.common-tags, {
    "Name"                                                            = "${var.project-name}-${var.env}-wp-public-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.project-name}-${var.env}-wp-cluster" = "owned"
    "kubernetes.io/role/elb"                                          = "1"
  })
}

resource "aws_subnet" "wp-private-subnet" {
  vpc_id                  = aws_vpc.wp-vpc.id
  count                   = length(var.private_subnet)
  cidr_block              = element(var.private_subnet, count.index)
  availability_zone       = element(data.aws_availability_zones.azones.names, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch_private
  tags = merge(var.common-tags, {
    "Name"                                                            = "${var.project-name}-${var.env}-wp-private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.project-name}-${var.env}-wp-cluster" = "owned"
    "kubernetes.io/role/internal-elb"                                 = "1"
  })
}

resource "aws_internet_gateway" "wp-igw" {
  vpc_id = aws_vpc.wp-vpc.id
  tags = merge(var.common-tags, {
    "Name" = "${var.project-name}-${var.env}-wp-igw"
  })
}

resource "aws_eip" "wp-eip" {
  count  = length(var.public_subnet)
  domain = "vpc"
  tags = merge(var.common-tags, {
    "Name" = "${var.project-name}-${var.env}-wp-eip-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "wp-ngw" {
  count         = length(var.public_subnet)
  allocation_id = element(aws_eip.wp-eip[*].id, count.index)
  subnet_id     = element(aws_subnet.wp-public-subnet[*].id, count.index)
  tags = merge(var.common-tags, {
    "Name" = "${var.project-name}-${var.env}-wp-ngw-${count.index + 1}"
  })
}

resource "aws_route_table" "wp-rtb-public" {
  vpc_id = aws_vpc.wp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wp-igw.id
  }
  tags = merge(var.common-tags, {
    "Name" = "${var.project-name}-${var.env}-wp-rtb-public"
  })
}

resource "aws_route_table" "wp-rtb-private" {
  count  = length(var.private_subnet)
  vpc_id = aws_vpc.wp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.wp-ngw[*].id, count.index)
  }
  tags = merge(var.common-tags, {
    "Name" = "${var.project-name}-${var.env}-wp-rtb-private-${count.index + 1}"
  })
}

resource "aws_route_table_association" "wp-rtb-public-assoc" {
  count          = length(var.public_subnet)
  subnet_id      = element(aws_subnet.wp-public-subnet[*].id, count.index)
  route_table_id = aws_route_table.wp-rtb-public.id
}

resource "aws_route_table_association" "wp-rtb-private-assoc" {
  count          = length(var.private_subnet)
  subnet_id      = element(aws_subnet.wp-private-subnet[*].id, count.index)
  route_table_id = element(aws_route_table.wp-rtb-private[*].id, count.index)
}