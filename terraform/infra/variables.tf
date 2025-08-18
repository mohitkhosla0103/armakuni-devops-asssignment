variable "provider_env_roles" {
  type    = map(string)
  default = {
    "dev"   =""
    "stage" =""
    "prod"  =""
    "qa"    =""
   
  }
}

variable "tags" {
  description = "Tags for the resources"
  type = object({ 
   
  })
}

variable "extra_tags" {
  description = "to add extra tags"
  type        = map(string)
  default     = {}
 }
#################################################################
#                          Networking                           #
#################################################################


variable "vpc_cidr" {
  type = string
  # Add description or default value if necessary
}

variable "vpc_name" {
  type = string
}

variable "eip_name" {
  type = string
}

variable "nat_gateway_name" {
  type = string
}

variable "internet_gateway_name" {
  type = string
}

variable "pub_route_table_name" {
  type = string
}

variable "priv_route_table_name" {
  type = string
}

variable "pub_route_dest_cidr" {
  type = string
}

variable "priv_route_dest_cidr" {
  type = string
}


# #################################################################
# #                          Loadbalancer                         #
# #################################################################
variable "alb_name" {
  type = string
}

variable "alb_idle_timeout" {
  type = string
}

variable "is_alb_internal" {
  description = "specify internal or external loadbalancer type"
  type = bool
  default = false
}

# #################################################################
# #                          S3                                   #
# #################################################################
variable "s3_bucket" {
   description = "S3-bucket"
  type = map(object({
    bucket             = string
    bucket_versioning  = string
  }))
}

# #################################################################
# #                          ECR                                  #
# #################################################################

variable "repositories" {
  description = "ecrs"
  type = map(object({
    name        = string
    image_tag_mutability =string
    scan_on_push = bool
    tags = map(string)
  }))
}

