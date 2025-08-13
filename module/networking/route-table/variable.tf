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

variable "rt-name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
  type = list(string)
}