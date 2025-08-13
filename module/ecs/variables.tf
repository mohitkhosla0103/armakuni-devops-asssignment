
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

variable "ecs_task_role" {
  type = string
}

variable "ecs_service_role" {
  type = string
}

variable "ecs_secrets_access_policy" {
  type = string
}

variable "ecs_secrets_access_policy_resource_arn" {
  type        = string
  description = "ECS secret access policy resource arn"
}

###############################################################################
#                              Load balncing                                  #
###############################################################################



variable "tg-name" {
  type    = string
  default = "aws-target-group"
}

variable "create_tg" {
  type    = bool
  default = false
}
variable "use_existing_tg" {
  type    = bool
  default = false
}

variable "existing_tg_arn" {
  type    = string
  default = ""
}

variable "create_ls" {
  type    = bool
  default = false
}

variable "create_lr" {
  type    = bool
  default = false
}

variable "load_balancer_arn" {
  type = string
}

variable "listener_arn" {
  type = string
}

variable "listener_rule_priority" {
  type    = number
  default = 10
}

variable "path_pattern" {
  type    = string
  default = "/api*"
}

variable "host_header" {
  type    = string
  //default = "example-site.com"
} 


variable "health_check_paths" {
  type    = map(string)
  default = {}
}
variable "health_check_path" {
  type    = string
  default = "/"
}

variable "health_check_interval" {
  type    = number
  default = 30
}

variable "health_check_timeout" {
  type    = number
  default = 10
}

variable "healthy_threshold" {
  type    = number
  default = 3
}

variable "unhealthy_threshold" {
  type    = number
  default = 3
}


###############################################################################
#                              ECS Service                                    #
###############################################################################

variable "container_runtime" {
  type = string
}

variable "ecs_task_family" {
  type = string

}

variable "network_mode" {
  type = string

}

variable "requires_compatibilities" {
  type = list(string)
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "cpu" {
  type    = number
  default = 256
}

variable "softLimit" {
  type    = number
  default = 256
}

variable "hardLimit" {
  type    = number
  default = 512
}

variable "ecs_container_image" {
  type = string

}

variable "port_mappings" {
  description = "A list of port mappings for the container"
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
    name          = string
    path_pattern  = string
    host_header   = string
  }))

}

variable "ecs_awslogs_group" {
  type    = string
  default = "ecs-logs-group-1"
}

variable "ecs_region" {
  type = string
}

variable "ecs_awslogs_stream" {
  type    = string
  default = "ecs-logs-stream-1"
}

variable "cpu_architecture" {
  type    = string
  default = "X86_64"
}


variable "ecs_service_name" {
  type = string

}

variable "ecs_service_cluster_id" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "scheduling_strategy" {
  type    = string
  default = "REPLICA"
}

variable "awslogs_region" {
  type = string
}

variable "ecs_container_name" {
  type = string

}

variable "vpc_id" {
  type = string
}

variable "attach_load_balancer" {
  type    = bool
  default = false
}

variable "security_group_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}


variable "env_task_defintions" {
  type = list(object({
    name  = string
    value = string
  }))
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
}

# variable "listener_arn" {
#   type = string
# }


variable "autoscaling_enabled" {
  type    = bool
  default = true
}

variable "max_capacity" {
  type = number
}

variable "min_capacity" {
  type = number
}



variable "ecs_service_cluster_name" {
  type = string
}

variable "is_internal_service"{
  type    = bool
}

variable "service_discovery_private_dns_id" {
  type = string
  default = ""
}