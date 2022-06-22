locals {
  full_cidr = "${var.subnet_prefix}.0.0/16"

  subnet_sizes = {
    "/22" = { newbits = 6, gap = 4 }
    "/23" = { newbits = 7, gap = 2 }
    "/24" = { newbits = 8, gap = 1 }
    "/25" = { newbits = 9, gap = 1 }
    "/26" = { newbits = 10, gap = 1 }
    "/27" = { newbits = 11, gap = 1 }
  }

  subnet_size = lookup(local.subnet_sizes[var.subnet_size], "newbits")
  subnet_gap  = lookup(local.subnet_sizes[var.subnet_size], "gap")
}

##########################################
# VPCs
##########################################

resource "aws_vpc" "main" {
  cidr_block = local.full_cidr

  tags = {
    "Name" = var.env_name
    "Tier" = var.env_name
  }
}

##########################################
# Internet gateways
##########################################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = var.env_name
  }
}

##########################################
# NAT gateways
##########################################

resource "aws_eip" "srvnat" {
  count = var.num_services_subnets

  vpc = true

  tags = {
    "Name" = "${var.env_name}-services-public"
  }
}

resource "aws_nat_gateway" "srvnat" {
  count = var.num_services_subnets

  allocation_id = aws_eip.srvnat[count.index].id
  subnet_id     = aws_subnet.srvpub[count.index].id

  tags = {
    "Name" = "${var.env_name}-services-public"
  }
}

resource "aws_eip" "dbnat" {
  count = var.enable_public_dbs ? var.num_database_subnets : 0

  vpc = true

  tags = {
    "Name" = "${var.env_name}-database-public"
  }
}

resource "aws_nat_gateway" "dbnat" {
  count = var.enable_public_dbs ? var.num_database_subnets : 0

  allocation_id = aws_eip.dbnat[count.index].id
  subnet_id     = aws_subnet.dbpub[count.index].id

  tags = {
    "Name" = "${var.env_name}-database-public"
  }
}

##########################################
# Route tables
##########################################

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    "Name" = "${var.env_name}-srv-pub"
  }
}

resource "aws_route_table" "srvprv" {
  count = var.num_services_subnets

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.srvnat[count.index].id
  }

  tags = {
    "Name" = "${var.env_name}-srv-prv"
  }
}

resource "aws_route_table" "dbprv" {
  count = var.num_database_subnets

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_public_dbs ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.dbnat[count.index].id
    }
  }

  tags = {
    "Name" = "${var.env_name}-db-prv"
  }
}

##########################################
# Subnets
##########################################

resource "aws_subnet" "srvpub" {
  count = var.num_services_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.full_cidr, local.subnet_size, count.index)
  availability_zone = "${var.region}${(count.index + 1) % 3 == 0 ? "c" : (count.index + 1) % 2 == 0 ? "b" : "a"}"

  tags = {
    "Name" = "${var.env_name}-services-public"
    "Tier" = "SRVPublic"
  }
}

resource "aws_route_table_association" "srvpub" {
  count = var.num_services_subnets

  subnet_id      = aws_subnet.srvpub[count.index].id
  route_table_id = aws_route_table.pub.id
}

resource "aws_subnet" "srvprv" {
  count = var.num_services_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.full_cidr, local.subnet_size, count.index + 25)
  availability_zone = "${var.region}${(count.index + 1) % 3 == 0 ? "c" : (count.index + 1) % 2 == 0 ? "b" : "a"}"

  tags = {
    "Name" = "${var.env_name}-services-private"
    "Tier" = "SRVPrivate"
  }
}

resource "aws_route_table_association" "srvprv" {
  count = var.num_services_subnets

  subnet_id      = aws_subnet.srvprv[count.index].id
  route_table_id = aws_route_table.srvprv[count.index].id
}

resource "aws_subnet" "dbpub" {
  count = var.enable_public_dbs ? var.num_database_subnets : 0

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.full_cidr, local.subnet_size, count.index + 50)
  availability_zone = "${var.region}${(count.index + 1) % 3 == 0 ? "c" : (count.index + 1) % 2 == 0 ? "b" : "a"}"

  tags = {
    "Name" = "${var.env_name}-database-public"
    "Tier" = "DBPublic"
  }
}

resource "aws_route_table_association" "dbpub" {
  count = var.enable_public_dbs ? var.num_database_subnets : 0

  subnet_id      = aws_subnet.dbpub[count.index].id
  route_table_id = aws_route_table.pub.id
}

resource "aws_subnet" "dbprv" {
  count = var.num_database_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.full_cidr, local.subnet_size, count.index + 75)
  availability_zone = "${var.region}${(count.index + 1) % 3 == 0 ? "c" : (count.index + 1) % 2 == 0 ? "b" : "a"}"

  tags = {
    "Name" = "${var.env_name}-database-private"
    "Tier" = "DBPrivate"
  }
}

resource "aws_route_table_association" "dbprv" {
  count = var.num_database_subnets

  subnet_id      = aws_subnet.dbprv[count.index].id
  route_table_id = aws_route_table.dbprv[count.index].id
}

