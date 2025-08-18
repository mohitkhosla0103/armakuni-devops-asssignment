################################################################
#                        Networking                           #
################################################################


module "vpc" {
  source = "../module/networking/vpc"

  cidr_block = var.vpc_cidr
  vpc-name   = var.vpc_name
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "pvt-sub" {
  source   = "../module/networking/subnet"
  for_each = { for pvt_subnets in flatten(local.pvt_subnets) : pvt_subnets.cidr_block => pvt_subnets }

  subnet-name       = each.value.subnet_name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  vpc_id            = module.vpc.vpc_id
  tags              = var.tags
  extra_tags        = var.extra_tags
}

module "pub-sub" {
  source   = "../module/networking/subnet"
  for_each = { for pub_subnets in flatten(local.pub_subnets) : pub_subnets.cidr_block => pub_subnets }

  subnet-name       = each.value.subnet_name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  vpc_id            = module.vpc.vpc_id
  tags              = var.tags
  extra_tags        = var.extra_tags
}

module "eip" {
  source = "../module/networking/elastic-ip"

  eip-name   = var.eip_name
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "natgw" {
  source = "../module/networking/nat-gateway"

  ng-name       = var.nat_gateway_name
  allocation_id = module.eip.eip_id
  subnet_id     = local.pub_subnet_ids[0]
  tags          = var.tags
  extra_tags    = var.extra_tags
}

module "internet_gateway" {
  source = "../module/networking/internet-gateway"

  ig-name    = var.internet_gateway_name
  vpc_id     = module.vpc.vpc_id
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "pub_route_table" {
  source = "../module/networking/route-table"

  rt-name    = var.pub_route_table_name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(local.pub_subnet_ids)
  # subnet_ids = concat(    // This will give accosiate igw to all subnets 
  #   local.pub_subnet_ids,
  #   local.pvt_subnet_ids 
  # )
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "pub_route" {
  source = "../module/networking/routes"

  route_table_id         = module.pub_route_table.route_table_ids
  destination_cidr_block = var.pub_route_dest_cidr // 0.0.0.0/0
  gateway_id             = module.internet_gateway.igw_id
}



module "pvt_route_table" {
  source = "../module/networking/route-table"

  rt-name    = var.priv_route_table_name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(local.pvt_subnet_ids)
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "pvt_route" {
  source = "../module/networking/routes"

  route_table_id         = module.pvt_route_table.route_table_ids
  destination_cidr_block = var.priv_route_dest_cidr
  nat_gateway_id         = module.natgw.natgw_ids
}


#################################################################
#                          Security Group                        #
#################################################################

module "dependent_security_group" {
  source = "../module/networking/dependent_security_group"

  for_each       = local.dependent_security_group
  sg_name        = each.value.name
  sg_description = each.value.description
  vpc_id         = module.vpc.vpc_id
  ingress_rules  = each.value.ingress_rules
  egress_rules   = each.value.egress_rules
  tags           = var.tags
  extra_tags     = var.extra_tags

}

module "independent_security_group" {
  source = "../module/networking/independent_security_group"

  for_each       = local.independent_security_group
  sg_name        = each.value.name
  sg_description = each.value.description
  vpc_id         = module.vpc.vpc_id
  ingress_rules  = each.value.ingress_rules
  egress_rules   = each.value.egress_rules
  tags           = var.tags
  extra_tags     = var.extra_tags

}


# # #################################################################
# # #                          Loadbalancing                        #
# # #################################################################
module "load_balancer" {
  source              = "../module/loadbalancer"
  tg_vpc              = module.vpc.vpc_id
  is_internal         = var.is_alb_internal
  alb_name            = var.alb_name
  alb_security_groups = [module.independent_security_group["${local.environment}-loadbalancer-sg"].sg_id]
  alb_subnets         = local.pub_subnet_ids
  idle_timeout        = var.alb_idle_timeout
  //certificate_arn                      = data.aws_acm_certificate.issued.arn 
  tags       = var.tags
  extra_tags = var.extra_tags
}


# #################################################################
# #                          S3                                   #
# #################################################################
module "s3" {
  source = "../module/s3"

  for_each          = var.s3_bucket
  bucket            = each.value.bucket
  bucket_versioning = each.value.bucket_versioning
  //bucket_policy                  = each.value.bucket_policy 
  tags       = var.tags
  extra_tags = var.extra_tags
}

# #################################################################
# #                          ECR                                  #
# #################################################################
module "ecr" {
  source = "../module/ecr"

  for_each   = var.repositories
  ecr_name   = each.value.name
  tags       = var.tags
  extra_tags = var.extra_tags

}


