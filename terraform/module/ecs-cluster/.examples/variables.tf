################################################################
#                             ECS                              #
################################################################



variable "ecs_cluster_name" {
  type = string
}

variable "capacity_provider_name" {
  type = string
}

variable "max_scaling_step_size" {
  type = string
  default = "1"
}

variable "ecs_template_name" {
  type = string
}

variable "ecs_instance_type" {
  type = string
  default = "t3.medium"
}

variable "ecs_volume_size" {
  type = number
  default = 30
}

variable "ecs_instance_volume_type" {
  type = string
  default = "gp3"
}

variable "enable_encryption" {
  type = bool
  default = false
}

variable "ecs_tag_value" {
  type = string
}

variable "ecs_asg_name" {
  type = string
}

variable "ecs_asg_min_size" {
  type = number
  default = 1
}

variable "ecs_asg_max_size" {
  type = number
  default = 2
}

variable "ecs_asg_desired_size" {
  type = number
  default = 1
}

variable "ecs_on_demand_cap" {
  type = number
  default = 0
}

variable "ecs_instance_profile_name" {
  type = string
}

variable "ecs_instance_role_name" {
  type = string
}

variable "spot_max_price" {
  type = string
}

variable "ecs_instance_ssh_name" {
  type = string
  default = ""
}
