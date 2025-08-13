module "internet_gateway" {
  source = "../modules/internet-gateway"

  ig-name = var.ig-name
  vpc_id  = module.vpc.vpc_id

  tags       = var.tags
  extra_tags = var.extra_tags
}