

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
  
}

variable "idle_timeout" {
 
  type        = string
  
}

variable "alb_subnets" {
  description = "List of subnet IDs where the ALB should be deployed"
  type        = list(string)
}

variable "alb_security_groups" {
  description = "List of security group IDs for the ALB"
  type        = list(string)
}

variable "is_internal" {
  type = bool
  default = false
}

variable "tg_vpc" {
  type = string
}


# variable "certificate_arn" {
#   type = string
# }



variable "tags" {
  description = "Tags to be applied to resources (inclusive)"
  type = object({
   
  })
}

variable "extra_tags" {
  description = "extra tags to be applied to resources."
  type        = map(string)
  default     = {}
}


