module "eip" {
  source = "../modules/elastic-ip"

  eip-name   = var.eip-name
  tags       = var.tags
  extra_tags = var.extra_tags
}