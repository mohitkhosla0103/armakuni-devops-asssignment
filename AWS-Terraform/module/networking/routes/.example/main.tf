module "pub_route" {
  source                 = "../modules/routes"
  route_table_id         = module.pub_route_table.route_table_ids
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.internet_gateway.igw_id
}

// To create private route use same approach as public route.

# module "pvt_route" {
#   source                 = "../modules/routes"
#   route_table_id         = module.pvt_route_table.route_table_ids
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = module.natgw.natgw_ids
# }