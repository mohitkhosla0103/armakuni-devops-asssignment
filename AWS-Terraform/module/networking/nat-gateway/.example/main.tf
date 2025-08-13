module "natgw" {
  source = "../modules/nat-gateway"

  ng-name       = var.ng-name
  allocation_id = module.eip.eip_id
  subnet_id     = local.pub_subnet_ids[0]

  tags       = var.tags
  extra_tags = var.extra_tags
}