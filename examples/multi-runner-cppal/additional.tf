
data "aws_route_table" "gha_public_rt" {
  vpc_id        = module.base.vpc.vpc_id
  tags		= {
    Name        = "gha-vpc-public"
  }
}

data "aws_route_table" "gha_private_rt" {
  vpc_id        = module.base.vpc.vpc_id
  tags		= {
    Name        = "gha-vpc-private"
  }
}

resource "aws_vpc_peering_connection" "peering1" {
  peer_vpc_id   = var.aws_default_vpc
  vpc_id        = module.base.vpc.vpc_id
  auto_accept   = true
}

resource "aws_route" "default_vpc_route_1" {
  route_table_id            = var.aws_default_route_table
  destination_cidr_block    = "10.0.1.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peering1.id
}

resource "aws_route" "default_vpc_route_2" {
  route_table_id            = var.aws_default_route_table
  destination_cidr_block    = "10.0.2.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peering1.id
}
resource "aws_route" "default_vpc_route_3" {
  route_table_id            = var.aws_default_route_table
  destination_cidr_block    = "10.0.3.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peering1.id
}
resource "aws_route" "default_vpc_route_101" {
  route_table_id            = var.aws_default_route_table
  destination_cidr_block    = "10.0.101.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peering1.id
}
resource "aws_route" "default_vpc_route_102" {
  route_table_id            = var.aws_default_route_table
  destination_cidr_block    = "10.0.102.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peering1.id
}
resource "aws_route" "default_vpc_route_103" {
  route_table_id            = var.aws_default_route_table
  destination_cidr_block    = "10.0.103.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peering1.id
}

resource "aws_route" "gha_vpc_route_public_1" {
   route_table_id            = data.aws_route_table.gha_public_rt.id
  destination_cidr_block    = var.aws_default_cidr_range
  vpc_peering_connection_id = aws_vpc_peering_connection.peering1.id
}

resource "aws_route" "gha_vpc_route_private_1" {
  route_table_id            = data.aws_route_table.gha_private_rt.id
  destination_cidr_block    = var.aws_default_cidr_range
  vpc_peering_connection_id = aws_vpc_peering_connection.peering1.id
}
