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

# #################################################################
# #                          Cloudfront                           #
# #################################################################
variable "cloudfront" {
   description = "Cloudfront"
  type = map(object({
    bucket_domain_name             = string
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

    ecs_container_name  = string
    ecr_repo_name       = string
    cpu                 = number
    softLimit           = number
    hardLimit           = number
    //path_pattern          = string
   // host_header           = string

    port_mappings= list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
    name          = string
    path_pattern          = string
    host_header           = string
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
    container_runtime    = string
    ecs_service_name     = string
    ecs_service_role     = string
    desired_count        = number
    scheduling_strategy  = string
    attach_load_balancer = bool
    ecs_service_cluster_name=string
    is_internal_service = bool
    
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



# ################################################################
# #                            ECS CI-CD                         #
# ################################################################
variable "ecs_cicd" {
  description = "Map of ECS service CI-CD configuration"
  type = map(object({


    /* -------------------------------- codebuild ------------------------------- */
    # codebuild_project_name = string
    # codebuild_role_name    = string
    codebuild_repo_policy_name         = string
    codebuild_repo_role_name           = string
    codebuild_repo_project_name        = string
    codebuild_repo_source_version      = string
    buildspec_file_name                = string
    codebuild_repo_project_description = string
    codebuild_repo_source_location     = string
    codebuild_repo_artifacts_name      = string
    branch_event_type                  = string
    branch_head_ref                    = string
    environment_variables              = map(string)


    /* ------------------------------ codepipeline ------------------------------ */
    codepipeline_name        = string
    codepipeline_policy_name = string
    codepipeline_role_name   = string
    ecs_service_name         = string
    ecs_service_cluster_name = string
    remote_party_owner       = string
    source_version_provider  = string
    connection_arn           = string
    remote_repo_name         = string
    remote_branch            = string
    remote_file_path         = string
    deployment_timeout       = number
    definition_file_name     = string
  }))
}

 ################################################################
# #                           SNS                                #
# ################################################################

variable "isFifo" {
  description = "Boolean variable to determine if the SNS topic should be FIFO. Default is false."
  type        = bool
  default     = false
}

variable "name" {
  description = "The name of the SNS topic."
  type        = string

}

variable "emails" {
  description = "List of emails"
  type        = list(string)
}



# ################################################################
# #                            Alarms                            #
# ################################################################

/* ------------------------------ Budget Alarm ------------------------------ */

variable "budget_name" {
  description = "The name of the budget"
  type        = string
}

variable "budget_amount" {
  description = "The budget amount"
  type        = number
  default     = 1000
}

variable "time_period_start" {
  description = "The start of the time period covered by the budget"
  type        = string
  default     = ""
}

variable "time_period_end" {
  description = "The end of the time period covered by the budget"
  type        = string
  default     = ""
}

variable "time_unit" {
  description = "The length of time until a budget resets"
  type        = string
  default     = "MONTHLY"
}

variable "subscriber_email_addresses" {
  description = "The email addresses to send notifications to"
  type        = list(string)
}

variable "threshold_values" {
  description = "The percentage thresholds to trigger notifications at"
  type        = list(number)
  default     = [85, 100]
}

variable "notification_type" {
  description = "The type of budget notification."
  type        = string
}

variable "comparison_operator" {
  description = "comperison operator"
  default     = "GREATER_THAN"
}


# ################################################################
# #                            Cloudwatch Dashboards             #
# ################################################################



variable "widget_files" {
 description = "List of paths to the JSON files for the widgets"
 type       = list(string)
    sensitive = true
 }
variable "dashboard_name" {
 description = "Name of Dashboard"
 type       = string
 }


# ################################################################
# #                            RDS                               #
# ################################################################


variable "rds_instances" {
  type = map(object({
    rds_app_name                     = string
    rds_environment                  = string
    rds_department                   = string
    rds_allocated_storage            = number
    rds_max_allocated_storage        = number
    rds_db_engine                    = string
    rds_db_engine_version            = number
    rds_instance_class               = string
    rds_db_name                      = string
    rds_skip_final_snapshot          = bool
    rds_multi_az                     = bool
    rds_performance_insights_enabled = bool
    rds_publicly_accessible          = bool
    rds_deletion_protection          = bool
    rds_storage_type                 = string
    rds_backup_retention_period      = number
  }))
}


# ################################################################
# #                   Aurora Global                              #
# ################################################################

// Common Aurora variables
variable "create_global_cluster" {
  type = bool
  
}

variable "rds_global_cluster_identifier" {
  type = string
  
}

# variable "aurora_master_username" {
#   type = string
  
# }

# variable "aurora_master_password" {
#   type = string
  
# }

variable "aurora_engine_version" {
  type = string
}

variable "aurora_engine" {
  type = string
  
}

variable "skip_final_snapshot" {
  
  type = bool
}

variable "aurora_cluster_copy_tags_to_snapshot" {
  type = bool
  
}

variable "aurora_port" {
  type = string
  
}

variable "aurora_cluster_parameter_group_family" {
  type = string
  
}

variable "db_parameter_group_family" {
  type = string
  
}

variable "aurora_serverless_min_acu_capacity" {
  type = string
  
}

variable "aurora_serverless_max_acu_capacity" {
  type = string
  
}

variable "aurora_deletion_protection" {
  type = bool
}

variable "aurora_cluster_engine_mode" {
  type = string
  
}

variable "cluster_backtrack_window" {
  type = string
  
}

variable "cluster_major_version_upgrade" {
  type = bool
  
}

variable "aurora_storage_type" {
  type = string
}

variable "aurora_storage_encrypted" {
  type = string
  
}

variable "cluster_backup_retention_period" {
  type = string
  
}

variable "aurora_min_read_replicas" {
  type = string
  
}

variable "aurora_max_read_replicas" {
  type = string
  
}

variable "aurora_target_metric_type" {
  type = string
  
}

variable "aurora_autoscaling_threshold_cpu" {
  type = string
  
}

variable "auroa_read_replica_scale_in_cooldown_period" {
  type = string
  
}

variable "aurora_read_replica_scale_out_cooldown_period" {
  type = string
  
}

variable "aurora_read_replica_autoscaling_policy_name" {
  type = string
  
}

// Primary aurora cluster variables
variable "primary_aurora_cluster_identifier" {
  type = string
  
}

variable "primary_db_cluster_preferred_backup_window" {
  type = string
  
}

variable "primary_db_cluster_preferred_maintenance_window" {
  type = string
  
}

variable "primary_instance_details" {
  type = map(object({    
    instance_class                           = string
    apply_immediately                        = bool
    availability_zone                        = string
    auto_minor_version_upgrade               = bool
    db_instance_copy_tags_to_snapshot        = bool
    monitoring_interval                      = number
    performance_insights_enabled             = bool
    performance_insights_kms_key_id          = string
    performance_insights_retention_period    = number
    db_instance_preferred_maintenance_window = string
    promotion_tier                           = number
    publicly_accessible                      = bool
  }))
}

//Secondary aurora cluster variables

variable "secondary_aurora_cluster_identifier" {
  type = string
  
}

variable "secondary_db_cluster_preferred_backup_window" {
  type = string
  
}

variable "secondary_db_cluster_preferred_maintenance_window" {
  type = string
  
}

variable "secondary_instance_details" {
  type = map(object({    
    instance_class                           = string
    apply_immediately                        = bool
    availability_zone                        = string
    auto_minor_version_upgrade               = bool
    db_instance_copy_tags_to_snapshot        = bool
    monitoring_interval                      = number
    performance_insights_enabled             = bool
    performance_insights_kms_key_id          = string
    performance_insights_retention_period    = number
    db_instance_preferred_maintenance_window = string
    promotion_tier                           = number
    publicly_accessible                  = bool
  }))
}

# ################################################################
# #                   Secret Manager                             #
# ################################################################


variable "secret_name" {
  description = "Name of the secret"
  type        = string
}

variable "secret_type" {
  description = "Type of the secret: either 'username_password' or 'single_string'"
  type        = string
  validation {
    condition     = contains(["username_password", "single_string"], var.secret_type)
    error_message = "secret_type must be 'username_password' or 'single_string'."
  }
}

# Only required if secret_type = "username_password"
variable "username" {
  description = "Username for the secret"
  type        = string
  default     = null
  sensitive = true
}

variable "password" {
  description = "Optional password. if not set, a random one will be generated"
  type        = string
  default     = null
  sensitive = true
}

# Only required if secret_type = "single_string"
variable "secret_value" {
  description = "The single string value to store in the secret"
  type        = string
  default     = null
  sensitive = true
}