variable "master_user_name" {
  type = string
  description = "Master user name"
}

variable "master_user_password" {
  type = string
  description = "Master user password"
}

variable "domain_name" {
  type = string
  description = "Domain name for open search"
}

variable "instance_count" {
  type = number
  default = 3
  description = "Number of instances"
}

variable "instance_type" {
  type = string
  default = "t3.medium.search"
  description = "Instance type"
}

variable "multi_az_with_standby_enabled" {
  type = bool
  default = false
  description = "Multi AZ with standby enabled"
}

variable "availability_zone_count" {
  type = number
  default = 3
  description = "Availability zone count"
}

variable "dedicated_master_count" {
  type = number
  default = 3
  description = "Dedicated master nodes count"
}

variable "dedicated_master_enabled" {
  type = bool
  default = false
  description = "Dedicated master nodes enabled of not"
}

variable "dedicated_master_type" {
  type = string
  default = "t3.medium.search"
  description = "Dedicated master nodes type"
}

variable "ebs_iops" {
  type = number
  default = 3000
  description = "EBS IOPS"
}

variable "ebs_throughput" {
  type = number
  default = 125
  description = "EBS throughput"
}

variable "ebs_volume_size" {
  type = number
  default = 30
  description = "EBS volume size"
}

variable "ebs_volume_type" {
  type = string
  default = "gp3"
  description = "EBS volume type"
}

variable "engine_version" {
  type = string
  description = "Engine version"
}

variable "network_access" {
  type = string
  description = "Network access type"
}

variable "security_group_ids" {
  type = list(string)
  description = "Security group ids"
}

variable "subnet_ids" {
  type = list(string)
  description = "Subnet ids"
}

# variable "access_policies" {
#   type = string
#   description = "Access policy of opensearch domains"
# }

variable "opensearch_resource_arn" {
  type = string
  description = "Opensearch domain ARN for access policy"
}

variable "auto_tune_enabled" {
  type = string
  default = "DISABLED"
  description = "Auto tune enabled"
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