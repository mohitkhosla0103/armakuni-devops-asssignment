variable "provider_env_roles" {
  type = map(string)
  default = {
    "dev"   = ""
    "stage" = ""
    "prod"  = ""
    "qa"    = ""

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
  type        = bool
  default     = false
}

# #################################################################
# #                          S3                                   #
# #################################################################
variable "s3_bucket" {
  description = "S3-bucket"
  type = map(object({
    bucket            = string
    bucket_versioning = string
  }))
}

# #################################################################
# #                          ECR                                  #
# #################################################################

variable "repositories" {
  description = "ecrs"
  type = map(object({
    name                 = string
    image_tag_mutability = string
    scan_on_push         = bool
    tags                 = map(string)
  }))
}

# ################################################################
# #                            ECS Cluster                       #
# ################################################################

variable "cluster_type" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "capacity_provider_name" {
  type = string
}

variable "max_scaling_step_size" {
  type = string
}

variable "ecs_template_name" {
  type = string
}

variable "ecs_instance_type" {
  type = string
}

variable "use_ec2_spot_instances" {
  type = bool
}

variable "ecs_volume_size" {
  type = number
}

variable "ecs_instance_volume_type" {
  type = string
}

variable "enable_encryption" {
  type = bool
}

variable "ecs_tag_value" {
  type = string
}

variable "ecs_asg_name" {
  type = string
}

variable "ecs_asg_min_size" {
  type = number
}

variable "ecs_asg_max_size" {
  type = number
}

variable "ecs_asg_desired_size" {
  type = number
}

variable "ecs_instance_profile_name" {
  type = string
}

variable "ecs_instance_role_name" {
  type = string
}

variable "ecs_instance_ssh_name" {
  type = string
}


# ################################################################
# #                            ECS Service                       #
# ################################################################

variable "ecs_service" {
  description = "Map of ECS service configuration"
  type = map(object({


    /* --------------------------- ecs task defintion --------------------------- */
    ecs_task_family          = string
    ecs_task_role            = string
    network_mode             = string
    requires_compatibilities = list(string)

    task_cpu    = number
    task_memory = number

    ecs_container_name = string
    ecr_repo_name      = string
    cpu                = number
    softLimit          = number
    hardLimit          = number
    //path_pattern          = string
    // host_header           = string

    port_mappings = list(object({
      containerPort = number
      hostPort      = number
      protocol      = string
      name          = string
      path_pattern  = string
      host_header   = string
    }))

    health_check_paths = map(string)


    env_task_defintions = list(object({
      name  = string
      value = string
    }))
    secrets = list(object({
      name      = string
      valueFrom = string
    }))
    ecs_awslogs_group = string
    # ecs_region               = string
    ecs_awslogs_stream                     = string
    cpu_architecture                       = string
    ecs_secrets_access_policy              = string
    ecs_secrets_access_policy_resource_arn = string



    /* ------------------------------- ECS service ------------------------------ */
    container_runtime        = string
    ecs_service_name         = string
    ecs_service_role         = string
    desired_count            = number
    scheduling_strategy      = string
    attach_load_balancer     = bool
    ecs_service_cluster_name = string
    is_internal_service      = bool

    /* ---------------------- target group & listener rules --------------------- */
    create_tg              = bool
    use_existing_tg        = bool
    existing_tg_arn        = string
    tg-name                = string
    create_lr              = bool
    listener_rule_priority = number




    //health_check_path     = string
    health_check_interval = number
    health_check_timeout  = number
    healthy_threshold     = number
    unhealthy_threshold   = number

    autoscaling_enabled = bool
    max_capacity        = number
    min_capacity        = number
  }))
}