variable "security_groups" {
  description = "Map of security group configurations"
  type = map(object({
    name        = string
    description = string
    ingress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = list(string)
      description     = string
      security_groups = list(string)
    }))
    egress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = list(string)
      description     = string
      security_groups = list(string)
    }))
    tags = map(string)
  }))
}