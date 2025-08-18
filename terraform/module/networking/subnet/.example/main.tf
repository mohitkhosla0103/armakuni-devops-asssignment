module "pvt-sub" {
  source   = "../modules/subnet"
  for_each = { for pvt_subnets in flatten(local.pvt_subnets) : pvt_subnets.cidr_block => pvt_subnets }

  subnet-name       = each.value.subnet_name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  vpc_id = module.vpc.vpc_id

  tags       = local.tags
  extra_tags = local.extra_tags
}

// Please refer below for Creating Public Subnet.

# module "pub-sub" {
#   source   = "../modules/subnet"
#   for_each = { for pub_subnets in flatten(local.pub_subnets) : pub_subnets.cidr_block => pub_subnets }

#   subnet-name       = each.value.subnet_name
#   cidr_block        = each.value.cidr_block
#   availability_zone = each.value.availability_zone

#   vpc_id = module.vpc.vpc_id

#   tags       = local.tags
#   extra_tags = local.extra_tags
# }