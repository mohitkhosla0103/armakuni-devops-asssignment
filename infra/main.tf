################################################################
#                        Networking                           #
################################################################


module "vpc" {
  source = "../module/networking/vpc"

  cidr_block                             = var.vpc_cidr
  vpc-name                               = var.vpc_name
  tags                                   = var.tags
  extra_tags                             = var.extra_tags
}

module "pvt-sub" {
  source = "../module/networking/subnet"
  for_each                               = { for pvt_subnets in flatten(local.pvt_subnets) : pvt_subnets.cidr_block => pvt_subnets }

  subnet-name                            = each.value.subnet_name
  cidr_block                             = each.value.cidr_block
  availability_zone                      = each.value.availability_zone
  vpc_id                                 = module.vpc.vpc_id
  tags                                   = var.tags
  extra_tags                             = var.extra_tags
}

module "pub-sub" {
  source = "../module/networking/subnet"
  for_each                               = { for pub_subnets in flatten(local.pub_subnets) : pub_subnets.cidr_block => pub_subnets }

  subnet-name                            = each.value.subnet_name
  cidr_block                             = each.value.cidr_block
  availability_zone                      = each.value.availability_zone
  vpc_id                                 = module.vpc.vpc_id
  tags                                   = var.tags
  extra_tags                             = var.extra_tags
}

module "eip" {
  source = "../module/networking/elastic-ip"

  eip-name                               = var.eip_name
  tags                                   = var.tags
  extra_tags                             = var.extra_tags
}

module "natgw" {
  source = "../module/networking/nat-gateway"

  ng-name                                = var.nat_gateway_name
  allocation_id                          = module.eip.eip_id
  subnet_id                              = local.pub_subnet_ids[0]
  tags                                   = var.tags
  extra_tags                             = var.extra_tags
}

module "internet_gateway" {
  source = "../module/networking/internet-gateway"

  ig-name                                = var.internet_gateway_name
  vpc_id                                 = module.vpc.vpc_id
  tags                                   = var.tags
  extra_tags                             = var.extra_tags
}

module "pub_route_table" {
  source = "../module/networking/route-table"

  rt-name                                = var.pub_route_table_name
  vpc_id                                 = module.vpc.vpc_id
  subnet_ids                             = concat(local.pub_subnet_ids)
  # subnet_ids = concat(    // This will give accosiate igw to all subnets 
  #   local.pub_subnet_ids,
  #   local.pvt_subnet_ids 
  # )
  tags                                   = var.tags
  extra_tags                             = var.extra_tags
}

module "pub_route" {
  source = "../module/networking/routes"

  route_table_id                         = module.pub_route_table.route_table_ids
  destination_cidr_block                 = var.pub_route_dest_cidr // 0.0.0.0/0
  gateway_id                             = module.internet_gateway.igw_id
}



module "pvt_route_table" {
  source = "../module/networking/route-table"

  rt-name                                = var.priv_route_table_name
  vpc_id                                 = module.vpc.vpc_id
  subnet_ids                             = concat(local.pvt_subnet_ids)
  tags                                   = var.tags
  extra_tags                             = var.extra_tags
}

module "pvt_route" {
  source = "../module/networking/routes"

  route_table_id                         = module.pvt_route_table.route_table_ids
  destination_cidr_block                 = var.priv_route_dest_cidr
  nat_gateway_id                         = module.natgw.natgw_ids
}


#################################################################
#                          Security Group                        #
#################################################################

module "dependent_security_group" {
  source = "../module/networking/dependent_security_group"

  for_each                               = local.dependent_security_group
  sg_name                                = each.value.name
  sg_description                         = each.value.description
  vpc_id                                 = module.vpc.vpc_id
  ingress_rules                          = each.value.ingress_rules
  egress_rules                           = each.value.egress_rules
  tags                                   = var.tags
  extra_tags                             = var.extra_tags

}

module "independent_security_group" {
  source = "../module/networking/independent_security_group"

  for_each                               = local.independent_security_group
  sg_name                                = each.value.name
  sg_description                         = each.value.description
  vpc_id                                 = module.vpc.vpc_id
  ingress_rules                          = each.value.ingress_rules
  egress_rules                           = each.value.egress_rules
  tags                                   = var.tags
  extra_tags                             = var.extra_tags

}


# # #################################################################
# # #                          Loadbalancing                        #
# # #################################################################
module "load_balancer" {
  source = "../module/loadbalancer"
  tg_vpc                                 = module.vpc.vpc_id
  is_internal                            = var.is_alb_internal
  alb_name                               = var.alb_name
  alb_security_groups                    = [module.independent_security_group["${local.environment}-loadbalancer-sg"].sg_id]
  alb_subnets                            = local.pub_subnet_ids
  idle_timeout                           = var.alb_idle_timeout
  //certificate_arn                      = data.aws_acm_certificate.issued.arn 
  tags                                   = var.tags
  extra_tags                             = var.extra_tags
 }


# #################################################################
# #                          S3                                   #
# #################################################################
module "s3" {
  source = "../module/s3"

  for_each                               = var.s3_bucket
  bucket                                 = each.value.bucket
  bucket_versioning                      = each.value.bucket_versioning
  //bucket_policy                  = each.value.bucket_policy 
  tags                                   = var.tags
  extra_tags                             = var.extra_tags
}

# #################################################################
# #                          ECR                                  #
# #################################################################
 module "ecr" {
  source   = "../module/ecr"

   for_each                              = var.repositories
   ecr_name                              = each.value.name
   tags                                  = var.tags
   extra_tags                            = var.extra_tags
  
}

# ################################################################
# #                            Cloudfront                        #
# ################################################################
module "cloudfront" {
  source = "../module/cloudfront"
  for_each                               = var.cloudfront
  bucket_domain_name                     = each.value.bucket_domain_name
  tags                                   = var.tags
  extra_tags                             = var.extra_tags

  depends_on                             = [module.s3]
}



# ################################################################
# #                            ECS Cluster                       #
# ################################################################



module "ecs_cluster" {
  source  = "../module/ecs-cluster"

  cluster_type                           = var.cluster_type
  cluster_name                           = var.ecs_cluster_name
  capacity_provider                      = var.capacity_provider_name
     
 
  maximum_scaling_step_size              = var.max_scaling_step_size
  #autoscaling_launch_template
  launch_template_name                   = var.ecs_template_name
  launch_template_instance_type          = var.ecs_instance_type
  user_data_script                       = local.encoded_userdata
  key_name                               = var.ecs_instance_ssh_name             
  security_group_ids                     = [module.dependent_security_group["${local.environment}-autoscaling-group-sg"].sg_id]
  ebs_volume_size                        = var.ecs_volume_size          
  ebs_volume_type                        = var.ecs_instance_volume_type 
  enable_encryption                      = true
  tag_value                              = var.ecs_tag_value
  #autoscaling_group
  # if you want to create all the spot instances then give true value to use_ec2_spot_instances variable and value false for all the on demand instance.
  use_ec2_spot_instances                 = var.use_ec2_spot_instances                //For ECS with EC2
  asg_name                               = var.ecs_asg_name
  min_size                               = var.ecs_asg_min_size     
  max_size                               = var.ecs_asg_max_size     
  desired_capacity                       = var.ecs_asg_desired_size 
  vpc_id                                 = module.vpc.vpc_id
  subnet_ids                             = local.pvt_subnet_ids
  ecs_instance_role_name                 = var.ecs_instance_role_name
  instance_profile                       = var.ecs_instance_profile_name
  tags                                   = var.tags
  extra_tags                             = var.extra_tags
 
}

# ################################################################
# #                            ECS Service                       #
# ################################################################
module "ecs_service" {
  source   = "../module/ecs"
  
  for_each                               = var.ecs_service
  container_runtime                      = each.value.container_runtime
  ecs_task_role                          = each.value.ecs_task_role
  ecs_service_role                       = each.value.ecs_service_role
  listener_rule_priority                 = each.value.listener_rule_priority

//Enter following 3 values in .tfvars for each port
  path_pattern                           = ""
  host_header                            = ""
  health_check_path                      = ""

  health_check_interval                  = each.value.health_check_interval
  health_check_timeout                   = each.value.health_check_timeout
  healthy_threshold                      = each.value.healthy_threshold
  unhealthy_threshold                    = each.value.unhealthy_threshold

  attach_load_balancer                   = each.value.attach_load_balancer
  security_group_ids                     = [module.dependent_security_group["${local.environment}-autoscaling-group-sg"].sg_id]
  private_subnet_ids                     = local.pvt_subnet_ids
 

  ecs_task_family                        = each.value.ecs_task_family
  ecs_secrets_access_policy              = each.value.ecs_secrets_access_policy
  ecs_secrets_access_policy_resource_arn = each.value.ecs_secrets_access_policy_resource_arn
  network_mode                           = each.value.network_mode
  requires_compatibilities               = each.value.requires_compatibilities

  cpu                                    = each.value.cpu
  task_cpu                               = each.value.task_cpu
  task_memory                            = each.value.task_memory
  softLimit                              = each.value.softLimit
  hardLimit                              = each.value.hardLimit

  port_mappings                          = each.value.port_mappings  
  health_check_paths                     = each.value.health_check_paths

  ecs_container_image                    = module.ecr[each.value.ecr_repo_name].ecr_url
  ecs_awslogs_group                      = each.value.ecs_awslogs_group
  ecs_region                             = data.aws_region.current.name
  ecs_awslogs_stream                     = each.value.ecs_awslogs_stream
  cpu_architecture                       = each.value.cpu_architecture
  ecs_service_name                       = each.value.ecs_service_name
  ecs_service_cluster_id                 = module.ecs_cluster.cluster_id
  desired_count                          = each.value.desired_count
  scheduling_strategy                    = each.value.scheduling_strategy
  awslogs_region                         = data.aws_region.current.name
  ecs_container_name                     = each.value.ecs_container_name
  vpc_id                                 = module.vpc.vpc_id

  ecs_service_cluster_name               = each.value.ecs_service_cluster_name

  env_task_defintions                    = each.value.env_task_defintions

  secrets                                = each.value.secrets

  create_tg                              = each.value.create_tg
  use_existing_tg                        = each.value.use_existing_tg
  existing_tg_arn                        = each.value.existing_tg_arn
  listener_arn                           = module.load_balancer.alb_http_listener_arn   //change this to https listener arn when domain available
  create_lr                              = each.value.create_lr

  load_balancer_arn                      = module.load_balancer.alb_arn
  tg-name                                = each.value.tg-name

  autoscaling_enabled                    = each.value.autoscaling_enabled
  max_capacity                           = each.value.max_capacity
  min_capacity                           = each.value.min_capacity

  is_internal_service                    = each.value.is_internal_service

  ## service_discovery_private_dns_id argument will be uncommented only if we are having atleast one internal service. 
  ## Otherwise for the external services it will be commented as we won't need to call the service discovery module.
  # service_discovery_private_dns_id       = each.value.is_internal_service == true ? module.service_discovery_private_dns.private_dns_name : ""
  
  tags                                   = var.tags
  extra_tags                             = var.extra_tags

  depends_on                             = [module.cicd]
}

# ################################################################
# #                           Service Discovery                  #
# ################################################################

## NOTE : Need to call below module whenever you want to create internal service

# module "service_discovery_private_dns" {
#   source   = "../module/servicediscovery"
  
#   vpc_id                                 = module.vpc.vpc_id
#   is_internal_service                    = true                             // providing value here because it will be created only one time.
#   ecs_service_cluster_name               = module.ecs_cluster.cluster_name
# }

# ################################################################
# #                            ECS CI-CD                         #
# ################################################################
module "cicd" {
  source   = "../module/ci-cd"
  for_each = var.ecs_cicd

   ecs_service_name                      = each.value.ecs_service_name
   ecs_service_cluster_name              = each.value.ecs_service_cluster_name
   ecs_region                            = data.aws_region.current.name

  codebuild_repo_policy_name             = each.value.codebuild_repo_policy_name
  codebuild_repo_project_description     = each.value.codebuild_repo_project_description
  codebuild_codepipeline_artifact_store  = module.s3["${local.environment}-my-proj-artifact-bucket"].s3_name
  codebuild_repo_artifacts_location      = module.s3["${local.environment}-my-proj-artifact-bucket"].s3_name
  codebuild_repo_role_name               = each.value.codebuild_repo_role_name
  codebuild_repo_project_name            = each.value.codebuild_repo_project_name
  codebuild_repo_source_version          = each.value.codebuild_repo_source_version
  codebuild_repo_source_location         = each.value.codebuild_repo_source_location
  codebuild_repo_artifacts_name          = each.value.codebuild_repo_artifacts_name
  branch_event_type                      = each.value.branch_event_type
  branch_head_ref                        = each.value.branch_head_ref
  environment_variables                  = each.value.environment_variables

  codepipeline_name                      = each.value.codepipeline_name              // Also creates new folder for each codepipeline build & source artifacts in artifact bucket 
  codepipeline_policy_name               = each.value.codepipeline_policy_name
  buildspec_file_name                    = each.value.buildspec_file_name
  codepipeline_role_name                 = each.value.codepipeline_role_name

  remote_party_owner                     = each.value.remote_party_owner
  source_version_provider                = each.value.source_version_provider
  connection_arn                         = each.value.connection_arn
  remote_repo_name                       = each.value.remote_repo_name
  remote_branch                          = each.value.remote_branch
  remote_file_path                       = each.value.remote_file_path
  deployment_timeout                     = each.value.deployment_timeout
  definition_file_name                   = each.value.definition_file_name

  tags                                   = var.tags
  extra_tags                             = var.extra_tags

  depends_on                             = [module.ecr,module.s3]
}

# ################################################################
# #                            EC2-Bastion                       #
# ################################################################

module "ec2_instances" {
  source = "../module/ec2"

  for_each                              = local.ec2_instances                 // Look for EC2 section in local.tf

  ec2_instance_name                      = each.value.ec2_instance_name       // Add ec2 instance name
  instance_type                         = each.value.instance_type            // Add ec2 instance type
  key_pair_name                         = each.value.key_pair_name            //Create ssh key-pair using console
  iam_instance_profile                  = each.value.iam_instance_profile
  subnet_id                             = each.value.subnet_id
  vpc_security_group_ids                = each.value.vpc_security_group_ids
  root_block_device_details             = each.value.root_block_device
  spot_instance_details                 = each.value.spot_instance_details
  user_data_script                      = each.value.user_data_script
  number_of_instances                   = each.value.number_of_instances
  tags                                  = var.tags
  extra_tags                            = var.extra_tags
}


# ################################################################
# #                            SNS                               #
# ################################################################
module "sns" {
  source = "./../module/sns"

  isFifo                                = var.isFifo
  emails                                = var.emails
  name                                  = var.name
  tags                                  = var.tags
  extra_tags                            = var.extra_tags
}


 

################################################################
#                            Alarms                            #
################################################################

module "budget_module" {
  source = "../module/alarms/budget_alarm"

  budget_name                           = var.budget_name
  budget_amount                         = var.budget_amount
  time_period_start                     = var.time_period_start
  time_period_end                       = var.time_period_end
  time_unit                             = var.time_unit
  subscriber_email_addresses            = var.subscriber_email_addresses
  comparison_operator                   = var.comparison_operator
  threshold_values                      = var.threshold_values
  notification_type                     = var.notification_type
}


module "cloudwatch_alarm" {
  source   = "../module/alarms/cloudwatch_alarm"

  alarms                                = local.alarm_definitions             // Look for EC2 section in local.tf
  tags                                  = var.tags
  extra_tags                            = var.extra_tags
  
}


# ################################################################
# #                       Cloudwatch Dashboard                   #
# ################################################################

module "aws_cloudwatch_dashboard" {
    source = "../module/cloudwatch_analytics/dashboard"
    dashboard_name                     = var.dashboard_name
    widget_files                       = var.widget_files
}

# ################################################################
# #                            RDS                               #
# ################################################################

module "rds" {
  source = "../module/rds"

  for_each                              = var.rds_instances

  db_instance_identifier                = each.value.rds_app_name
  allocated_storage                     = each.value.rds_allocated_storage
  max_allocated_storage                 = each.value.rds_max_allocated_storage
  db_name                               = each.value.rds_db_name
  engine                                = each.value.rds_db_engine
  engine_version                        = each.value.rds_db_engine_version
  instance_class                        = each.value.rds_instance_class
  master_username                       = local.rds_creds[each.key].username                                  // Check creds in local.tf under RDS section
  master_password                       = local.rds_creds[each.key].password                                  // Check creds in local.tf under RDS section
  skip_final_snapshot                   = each.value.rds_skip_final_snapshot
  rds_final-snapshot_name               = "${each.value.rds_app_name}-final-snapshot"                          // delete this snapshot using console if already present during deletion of rds 
  multi_az                              = each.value.rds_multi_az
  performance_insights_enabled          = each.value.rds_performance_insights_enabled
  publicly_accessible                   = each.value.rds_publicly_accessible
  storage_type                          = each.value.rds_storage_type
  vpc_security_group_ids                = [module.dependent_security_group["${local.environment}-rds-sg"].sg_id]
  backup_retention_period               = each.value.rds_backup_retention_period
  rds_deletion_protection               = each.value.rds_deletion_protection                                    // Keep this value false during deletion of rds, otherwise keep true
  db_parameter_group_name               = "${each.value.rds_app_name}-db-parameter-group"
  db_parameter_group_family             = "${each.value.rds_db_engine}16"

  db_subnet_group_name                  = "${each.value.rds_app_name}-db-subnet-group"
  db_subnet_ids                         = local.pvt_subnet_ids
  db_subnet_group_tags                  = {
    Name                                = "${each.value.rds_app_name}-db-subnet-group"
    Enviromet                           = each.value.rds_environment
    Department                          = each.value.rds_department
    TerraformManaged                    = true
  }
  tags                                  = var.tags
  extra_tags                            = var.extra_tags
}



# ################################################################
# #                            Aurora Global CLuster             #
# ################################################################

// create multi-region key for global aurora cluster    //For non-global cluster we can use single region key 
module kms_aurora{
  source = "../module/aurora/kms-aurora"

  secondary_region                   = "us-east-2"    // (check in kms-aurora module)
  kms_aurora_alias_name              = "alias/global-kms"
  

}

module primary_aurora_cluster{
  source = "../module/aurora"

     //Parameters specific to global cluster
    create_global_cluster                         = var.create_global_cluster
    global_cluster_identifier                     = var.rds_global_cluster_identifier
    master_username                               = local.rds_creds["rds1"].username
    master_password                               = local.rds_creds["rds1"].password 
    engine_version                                = var.aurora_engine_version
    engine                                        = var.aurora_engine
    skip_final_snapshot                           = var.skip_final_snapshot 
    db_cluster_copy_tags_to_snapshot              = var.aurora_cluster_copy_tags_to_snapshot
    port                                          = var.aurora_port 
    db_cluster_parameter_group_family             = var.aurora_cluster_parameter_group_family
    db_parameter_group_family                     = var.db_parameter_group_family
    serverless_min_acu_capacity                   = var.aurora_serverless_min_acu_capacity
    serverless_max_acu_capacity                   = var.aurora_serverless_max_acu_capacity
    deletion_protection                           = var.aurora_deletion_protection
    cluster_engine_mode                           = var.aurora_cluster_engine_mode
    cluster_backtrack_window                      = var.cluster_backtrack_window
    cluster_major_version_upgrade                 = var.cluster_major_version_upgrade
    storage_type                                  = var.aurora_storage_type
    storage_encrypted                             = var.aurora_storage_encrypted
    backup_retention_period                       = var.cluster_backup_retention_period 
    
    //Aurora Read Replica Autoscaling
    min_read_replicas                             = var.aurora_min_read_replicas
    max_read_replicas                             = var.aurora_max_read_replicas
    target_metric                                 = var.aurora_target_metric_type //"RDSReaderAverageCPUUtilization"
    target_metric_value                           = var.aurora_autoscaling_threshold_cpu
    scale_in_cooldown_period                      = var.auroa_read_replica_scale_in_cooldown_period
    scale_out_cooldown_period                     = var.aurora_read_replica_scale_out_cooldown_period
    autoscaling_policy_name                       = var.aurora_read_replica_autoscaling_policy_name

     //parameters specific to primary cluster
    is_primary_cluster                            = true                                              // Mention true for primary & false for secondary cluster
    cluster_identifier                            = var.primary_aurora_cluster_identifier
    kms_key_id                                    = module.kms_aurora.primary_region_key.arn          //primary region kms aurora
    final_snapshot_identifier                     = "${var.primary_aurora_cluster_identifier}"             
    db_parameter_group_name                       = "${var.primary_aurora_cluster_identifier}-db-parameter-group"
    db_cluster_parameter_group_name               = "${var.primary_aurora_cluster_identifier}-cluster-parameter-group"
    db_cluster_preferred_backup_window            = var.primary_db_cluster_preferred_backup_window
    db_cluster_preferred_maintenance_window       = var.primary_db_cluster_preferred_maintenance_window

    instance_details                              = var.primary_instance_details
    rds_subnet_name                               = "${var.primary_aurora_cluster_identifier}-db-parameter-group"
    rds_subnet_group_ids                          = local.pvt_subnet_ids                                            //specify primary network subnet from module
    aurora_security_group_ids                     = [module.dependent_security_group["${local.environment}-rds-sg"].sg_id]        // specify primary network rds security group
    tags                                          = var.tags
    extra_tags                                    = var.extra_tags

}

//-------------------------------------------------------------------second network for aurora global secondary cluster (different region)------------------------

// Note: VPC IDs of primary & secondary network should not overlap.....Also vpc peering should be done manually
module "second_network" {
    source = "../module/aurora/secondary_network"
     count = "${local.environment}" == "prod" ? 1 : 0
         providers = {
        aws = aws.useast2
    }
}

// For demo I am creating security group resource for secondary network....in projects create separate module for secondary network
resource "aws_security_group" "rds_group" {
    count = "${local.environment}" == "prod" ? 1 : 0
          provider = aws.useast2

  name        = "secondary-rds-sg"
  description = "Allows access to postgres"
  vpc_id      = module.second_network[0].vpc_id
 
 tags = {
    terraform = true
   Environment="amano"
    Project="amano"
  }

  ingress {
    description = "DB access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


module secondary_aurora_cluster{
  source = "../module/aurora"
   count = "${local.environment}" == "prod" ? 1 : 0
   providers = {
      aws=aws.useast2
    }

    //Parameters specific to global cluster
    create_global_cluster                         = var.create_global_cluster
    global_cluster_identifier                     = var.rds_global_cluster_identifier
    master_username                               = local.rds_creds["rds1"].username
    master_password                               = local.rds_creds["rds1"].password 
    engine_version                                = var.aurora_engine_version
    engine                                        = var.aurora_engine
    skip_final_snapshot                           = var.skip_final_snapshot 
    db_cluster_copy_tags_to_snapshot              = var.aurora_cluster_copy_tags_to_snapshot
    port                                          = var.aurora_port 
    db_cluster_parameter_group_family             = var.aurora_cluster_parameter_group_family
    db_parameter_group_family                     = var.db_parameter_group_family
    serverless_min_acu_capacity                   = var.aurora_serverless_min_acu_capacity
    serverless_max_acu_capacity                   = var.aurora_serverless_max_acu_capacity
    deletion_protection                           = var.aurora_deletion_protection
    cluster_engine_mode                           = var.aurora_cluster_engine_mode
    cluster_backtrack_window                      = var.cluster_backtrack_window
    cluster_major_version_upgrade                 = var.cluster_major_version_upgrade
    storage_type                                  = var.aurora_storage_type
    storage_encrypted                             = var.aurora_storage_encrypted
    backup_retention_period                       = var.cluster_backup_retention_period 
    
    //Aurora Read Replica Autoscaling
    min_read_replicas                             = var.aurora_min_read_replicas
    max_read_replicas                             = var.aurora_max_read_replicas
    target_metric                                 = var.aurora_target_metric_type //"RDSReaderAverageCPUUtilization"
    target_metric_value                           = var.aurora_autoscaling_threshold_cpu
    scale_in_cooldown_period                      = var.auroa_read_replica_scale_in_cooldown_period
    scale_out_cooldown_period                     = var.aurora_read_replica_scale_out_cooldown_period
    autoscaling_policy_name                       = var.aurora_read_replica_autoscaling_policy_name

    //parameters specific to secondary cluster
    is_primary_cluster                            = false                                             // Mention true for primary & false for secondary cluster
    cluster_identifier                            = var.secondary_aurora_cluster_identifier
    kms_key_id                                    = module.kms_aurora.secondary_region_key.arn          //secondary region kms aurora
    final_snapshot_identifier                     = "${var.secondary_aurora_cluster_identifier}"             
    db_parameter_group_name                       = "${var.secondary_aurora_cluster_identifier}-db-parameter-group"
    db_cluster_parameter_group_name               = "${var.secondary_aurora_cluster_identifier}-cluster-parameter-group"
    db_cluster_preferred_backup_window            = var.secondary_db_cluster_preferred_backup_window
    db_cluster_preferred_maintenance_window       = var.secondary_db_cluster_preferred_maintenance_window

    instance_details                              = var.secondary_instance_details
    rds_subnet_name                               = "${var.secondary_aurora_cluster_identifier}-db-parameter-group"
    rds_subnet_group_ids                          = module.second_network[0].db_subnet_ids                              //specify secondary network subnet from module
    aurora_security_group_ids                     = [aws_security_group.rds_group[0].id]                                             // specify secondary network rds security group 
    tags                                          = var.tags
    extra_tags                                    = var.extra_tags

    depends_on = [ module.primary_aurora_cluster ]

}


# ################################################################
# #                            Secret Manager                    #
# ################################################################


# Data Source
module "secret"  {
  source = "../module/secret-manager"

  secret_name = var.secret_name
  secret_type = var.secret_type
  username = var.username
}