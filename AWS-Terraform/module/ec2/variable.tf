
/* -------------------------------- variables ------------------------------- */
variable "ec2_instance_name" {
  description = "Name of the instance you need"
  type        = string
}




# instance type
variable "instance_type" {
  description = "Type of the instance you need"
  type        = string
  default     = "t4g.medium"
}

# key pair
variable "key_pair_name" {
  description = "Key pair name for the EC2"
  type        = string
  default = ""
}

# iam instance profile name
variable "iam_instance_profile" {
  description = "Details of the iam instance profile"
  type = object({
    create_new_instance_profile      = bool
    custom_iam_instance_profile_name = string

    iam_role_name                 = string
    create_inline_policy          = bool
    inline_iam_policy_name        = string
    inline_iam_policy_description = string
    inline_policy_actions         = list(string)
    inline_policy_resource        = string

    attach_managed_policy = bool
    managed_policy_arns   = list(string)

    use_existing_instance_profile  = bool
    existing_instance_profile_name = string
  })
}

# VPC subnet Id
variable "subnet_id" {
  description = "VPC subnet id to launch EC2 in"
  type        = string
}

# VPC security group Id
variable "vpc_security_group_ids" {
  description = "List of security groups ids"
  type        = list(string)
}

# Root Block Device specifications
variable "root_block_device_details" {
  description = "EBS details"
  type = object({
    volume_type           = string
    volume_size           = string
    delete_on_termination = bool
  })
}

# spot instance specifications
variable "spot_instance_details" {
  description = "Spot instance details"
  type        = map(string)
  default = {}
}

# USERDATA script
variable "user_data_script" {
  description = "User data script for the Launch Template"
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "Tags for the resources"
  type = object({
  })
  
}

# Additional Tags
variable "extra_tags" {
  description = "For additional tags"
  type        = map(string)
  default     = {}
}

# Number of Instances
variable "number_of_instances" {
  description = "Number of Instances to create"
  type        = number
  default     = 1
}
