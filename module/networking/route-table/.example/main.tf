module "pub_route_table" {
  source = "../modules/route-table"

  rt-name = var.rt-name
  vpc_id  = module.vpc.vpc_id


  subnet_ids = concat(local.pub_subnet_ids)
  
  tags       = var.tags
  extra_tags = var.extra_tags
}

// To create private route-table use same approach as public route-table.

# module "pvt_route_table" {
#   source = "../modules/route-table"

#   rt-name    = var.rt-name
#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = concat(local.pvt_subnet_ids)

#   tags       = var.tags
#   extra_tags = var.extra_tags
# }
