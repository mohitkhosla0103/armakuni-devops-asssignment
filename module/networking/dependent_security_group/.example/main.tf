module "security_group" {
  source        = "../modules/security-groups"
  for_each      = var.security_groups
  sg-name       = each.value.name
  description   = each.value.description
  vpc_id        = module.vpc.vpc_id
  ingress_rules = each.value.ingress_rules
  egress_rules  = each.value.egress_rules

}