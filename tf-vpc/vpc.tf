resource "aws_vpc" "this" {
  #cidr_block            = "10.0.0.0/16"
  cidr_block            = var.vpc_configuration.cidr_block
  enable_dns_hostnames  = true
  enable_dns_support    = true
} # representa a caixa verde da VPC no diagrama


resource "aws_internet_gateway" "name" {
  vpc_id = aws_vpc.this.id
} # representa o icone Internet gateway no diagrama


resource "aws_subnet" "this" {
  #count = 6
  for_each = { for subnet in var.vpc_configuration.subnets : subnet.name => subnet }

  availability_zone_id    = local.az_pairs[each.key]
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = each.key
  }
} # cria as subnets com base no arquivo variables.tf 


resource "aws_nat_gateway" "this" {
  for_each = toset(locals.private_subnets)

  allocation_id = aws_eip.nat_gateway[each.value].id
  # precisa do elastic IP
  subnet_id = aws_subnet.this[local.subnet_pairs[each.value]].id
}


resource "aws_eip" "nat_gateway" {
  for_each = toset(local.private_subnets)
  vpc      = true

  depends_on = [aws_internet_gateway.this]
}