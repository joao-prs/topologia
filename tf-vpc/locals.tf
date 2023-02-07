locals {
  private_subnets = sort([ for subnet in var.vpc_configuration.subnets : subnet.name if subnet.public == false])
  public_subnets  = sort([ for subnet in var.vpc_configuration.subnets : subnet.name if subnet.public == false])
  azs             = sort(slice(data.aws_availability_zones.available.zone_ids, 0, length(local.private_subnets)))
  subnet_pairs    = zipmap(local.private_subnets, local.public_subnets)

  az_pairs = merge(
    zipmap(local.private_subnets, local.azs),
    zipmap(local.public_subnets, local.azs),
  )
} # este pedaço de codigo organiza as subnets privadas e publicas nas zonas disponiveis

# 'azs' é a posicao do contador, indicando que a subnet 1 vai estar na zona 1 e assim sucessivamente.