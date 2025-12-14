// create vpc (main network resource)

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr // the overall IP range for the VPC (e.g. 10.0.0.0/16)
  enable_dns_hostnames = true         // required for  normal DNS resolution
  enable_dns_support   = true         // needed for EC2 hostnames,RDS instances, etc.
  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}

// Internet gateway, attaches VPC to the public internet
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

// Public subnets, allow internet access via IGW
resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(var.tags, {
    Name = "${var.name}-public-${count.index + 1}"
    Tier = "public"
  })

}

// Private subnets, no direct internet access
resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(var.tags, {
    Name = "${var.name}-private-${count.index + 1}"
    Tier = "private"
  })
}

// public route table, (for public subnets)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-public-rt"
  })
}

// private route table, (for private subnets)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-private-rt"
  })
}

// route: send 0.0.0.0/0 to traffic from public subnets to IGW
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

// associate each public subnet with public route table
resource "aws_route_table_association" "public_internet_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

// allocate elastic IP for NAT gateway (static public IP)
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.name}-nat-eip"
  })
}

// NAT gateway in the first public subnet
// private subnets use this to reach the internet (outbound only)
resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-gw"
    }
  )

  depends_on = [aws_internet_gateway.this] // ensure IGW exists first
}

// route: send 0.0.0.0/0 traffic from private subnets to NAT gateway
resource "aws_route" "private_internet_access" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

// associate each private subnet with the private route table
resource "aws_route_table_association" "private_assoc" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
