variable "ingress_rules" {
  type = list(any)
  default = [  ]
}

variable "vpc_id" {
  type = string
  description = "id of vpc"
}
variable "sg_name" {
  type = string
  
}

variable "egress_rules" {
  type = list(any)
  default = [  ]
}

variable "sg_description" {
  type = string
  default = "value"
}

variable "tags" {
  description = "Tags to be applied to resources (inclusive)"
  type = object({
   
  })
}

variable "extra_tags" {
  description = "extra tags to be applied to resources (in addition to the tags above)"
  type        = map(string)
  default     = {}
}

