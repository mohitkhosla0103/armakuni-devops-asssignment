module "vpc" {
  source = "../modules/vpc"

  cidr_block = var.cidr_block

  vpc-name   = var.vpc-name
  tags       = var.tags
  extra_tags = var.extra_tags
}