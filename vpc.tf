resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  assign_generated_ipv6_cidr_block = true
  tags                             = merge(var.common_tags, { Name = var.vpc_name })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.common_tags, { Name = var.vpc_name })
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_public_cidr
  availability_zone = format("%sa", var.aws_region)
  tags              = merge(var.common_tags, var.public_subnet_tags, { Name = format("%s Public A", var.vpc_name) })
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_a_cidr
  availability_zone = format("%sa", var.aws_region)
  tags              = merge(var.common_tags, var.private_subnet_tags, { Name = format("%s Private A", var.vpc_name) })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_b_cidr
  availability_zone = format("%sb", var.aws_region)
  tags              = merge(var.common_tags, var.private_subnet_tags, { Name = format("%s Private B", var.vpc_name) })
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_c_cidr
  availability_zone = format("%sc", var.aws_region)
  tags              = merge(var.common_tags, var.private_subnet_tags, { Name = format("%s Private C", var.vpc_name) })
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.common_tags, { Name = format("%s Public", var.vpc_name) })
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.common_tags, { Name = format("%s Private", var.vpc_name) })
}

resource "aws_route_table_association" "rtb_public_assoc" {
  route_table_id = aws_route_table.public_rtb.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_route_table_association" "rtb_private_a_assoc" {
  route_table_id = aws_route_table.private_rtb.id
  subnet_id      = aws_subnet.private_a.id
}

resource "aws_route_table_association" "rtb_private_b_assoc" {
  route_table_id = aws_route_table.private_rtb.id
  subnet_id      = aws_subnet.private_b.id
}

resource "aws_route_table_association" "rtb_private_c_assoc" {
  route_table_id = aws_route_table.private_rtb.id
  subnet_id      = aws_subnet.private_b.id
}


resource "aws_security_group" "public" {
  name        = "public"
  description = "Allow https inbound traffic from public Internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    # YOU PROBABLY NEVER WANT TO DO THIS
    # PLEASE USE A LIMITED SOURCE IP RANGE
    description = "Allow ssh inbound traffic from public Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, { Name = "public-alb" })
}
