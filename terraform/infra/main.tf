################################################################
#                        Networking                           #
################################################################


module "vpc" {
  source = "../module/networking/vpc"

  cidr_block = var.vpc_cidr
  vpc-name   = var.vpc_name
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "pvt-sub" {
  source   = "../module/networking/subnet"
  for_each = { for pvt_subnets in flatten(local.pvt_subnets) : pvt_subnets.cidr_block => pvt_subnets }

  subnet-name       = each.value.subnet_name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  vpc_id            = module.vpc.vpc_id
  tags              = var.tags
  extra_tags        = var.extra_tags
}

module "pub-sub" {
  source   = "../module/networking/subnet"
  for_each = { for pub_subnets in flatten(local.pub_subnets) : pub_subnets.cidr_block => pub_subnets }

  subnet-name       = each.value.subnet_name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  vpc_id            = module.vpc.vpc_id
  tags              = var.tags
  extra_tags        = var.extra_tags
}

module "eip" {
  source = "../module/networking/elastic-ip"

  eip-name   = var.eip_name
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "natgw" {
  source = "../module/networking/nat-gateway"

  ng-name       = var.nat_gateway_name
  allocation_id = module.eip.eip_id
  subnet_id     = local.pub_subnet_ids[0]
  tags          = var.tags
  extra_tags    = var.extra_tags
}

module "internet_gateway" {
  source = "../module/networking/internet-gateway"

  ig-name    = var.internet_gateway_name
  vpc_id     = module.vpc.vpc_id
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "pub_route_table" {
  source = "../module/networking/route-table"

  rt-name    = var.pub_route_table_name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(local.pub_subnet_ids)
  # subnet_ids = concat(    // This will give accosiate igw to all subnets 
  #   local.pub_subnet_ids,
  #   local.pvt_subnet_ids 
  # )
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "pub_route" {
  source = "../module/networking/routes"

  route_table_id         = module.pub_route_table.route_table_ids
  destination_cidr_block = var.pub_route_dest_cidr // 0.0.0.0/0
  gateway_id             = module.internet_gateway.igw_id
}



module "pvt_route_table" {
  source = "../module/networking/route-table"

  rt-name    = var.priv_route_table_name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(local.pvt_subnet_ids)
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "pvt_route" {
  source = "../module/networking/routes"

  route_table_id         = module.pvt_route_table.route_table_ids
  destination_cidr_block = var.priv_route_dest_cidr
  nat_gateway_id         = module.natgw.natgw_ids
}


#################################################################
#                          Security Group                        #
#################################################################

module "dependent_security_group" {
  source = "../module/networking/dependent_security_group"

  for_each       = local.dependent_security_group
  sg_name        = each.value.name
  sg_description = each.value.description
  vpc_id         = module.vpc.vpc_id
  ingress_rules  = each.value.ingress_rules
  egress_rules   = each.value.egress_rules
  tags           = var.tags
  extra_tags     = var.extra_tags

}

module "independent_security_group" {
  source = "../module/networking/independent_security_group"

  for_each       = local.independent_security_group
  sg_name        = each.value.name
  sg_description = each.value.description
  vpc_id         = module.vpc.vpc_id
  ingress_rules  = each.value.ingress_rules
  egress_rules   = each.value.egress_rules
  tags           = var.tags
  extra_tags     = var.extra_tags

}


# # #################################################################
# # #                          Loadbalancing                        #
# # #################################################################
module "load_balancer" {
  source              = "../module/loadbalancer"
  tg_vpc              = module.vpc.vpc_id
  is_internal         = var.is_alb_internal
  alb_name            = var.alb_name
  alb_security_groups = [module.independent_security_group["${local.environment}-loadbalancer-sg"].sg_id]
  alb_subnets         = local.pub_subnet_ids
  idle_timeout        = var.alb_idle_timeout
  //certificate_arn                      = data.aws_acm_certificate.issued.arn 
  tags       = var.tags
  extra_tags = var.extra_tags
}


# #################################################################
# #                          S3                                   #
# #################################################################
module "s3" {
  source = "../module/s3"

  for_each          = var.s3_bucket
  bucket            = each.value.bucket
  bucket_versioning = each.value.bucket_versioning
  //bucket_policy                  = each.value.bucket_policy 
  tags       = var.tags
  extra_tags = var.extra_tags
}

# #################################################################
# #                          ECR                                  #
# #################################################################
module "ecr" {
  source = "../module/ecr"

  for_each   = var.repositories
  ecr_name   = each.value.name
  tags       = var.tags
  extra_tags = var.extra_tags

}

# ################################################################
# #                            ECS Cluster                       #
# ################################################################

module "ecs_cluster" {
  source = "../module/ecs-cluster"

  cluster_type      = var.cluster_type
  cluster_name      = var.ecs_cluster_name
  capacity_provider = var.capacity_provider_name


  maximum_scaling_step_size = var.max_scaling_step_size
  #autoscaling_launch_template
  launch_template_name          = var.ecs_template_name
  launch_template_instance_type = var.ecs_instance_type
  user_data_script              = local.encoded_userdata
  key_name                      = var.ecs_instance_ssh_name
  security_group_ids            = [module.dependent_security_group["${local.environment}-autoscaling-group-sg"].sg_id]
  ebs_volume_size               = var.ecs_volume_size
  ebs_volume_type               = var.ecs_instance_volume_type
  enable_encryption             = true
  tag_value                     = var.ecs_tag_value
  #autoscaling_group
  # if you want to create all the spot instances then give true value to use_ec2_spot_instances variable and value false for all the on demand instance.
  use_ec2_spot_instances = var.use_ec2_spot_instances //For ECS with EC2
  asg_name               = var.ecs_asg_name
  min_size               = var.ecs_asg_min_size
  max_size               = var.ecs_asg_max_size
  desired_capacity       = var.ecs_asg_desired_size
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = local.pvt_subnet_ids
  ecs_instance_role_name = var.ecs_instance_role_name
  instance_profile       = var.ecs_instance_profile_name
  tags                   = var.tags
  extra_tags             = var.extra_tags

}

# ################################################################
# #                            ECS Service                       #
# ################################################################
module "ecs_service" {
  source = "../module/ecs"

  for_each               = var.ecs_service
  container_runtime      = each.value.container_runtime
  ecs_task_role          = each.value.ecs_task_role
  ecs_service_role       = each.value.ecs_service_role
  listener_rule_priority = each.value.listener_rule_priority

  //Enter following 3 values in .tfvars for each port
  path_pattern      = ""
  host_header       = ""
  health_check_path = ""

  health_check_interval = each.value.health_check_interval
  health_check_timeout  = each.value.health_check_timeout
  healthy_threshold     = each.value.healthy_threshold
  unhealthy_threshold   = each.value.unhealthy_threshold

  attach_load_balancer = each.value.attach_load_balancer
  security_group_ids   = each.value.is_internal_service ? [module.independent_security_group["${local.environment}-private-ecs-sg"].sg_id] : [module.dependent_security_group["${local.environment}-autoscaling-group-sg"].sg_id]
  private_subnet_ids   = local.pvt_subnet_ids


  ecs_task_family                        = each.value.ecs_task_family
  ecs_secrets_access_policy              = each.value.ecs_secrets_access_policy
  ecs_secrets_access_policy_resource_arn = each.value.ecs_secrets_access_policy_resource_arn
  network_mode                           = each.value.network_mode
  requires_compatibilities               = each.value.requires_compatibilities

  cpu         = each.value.cpu
  task_cpu    = each.value.task_cpu
  task_memory = each.value.task_memory
  softLimit   = each.value.softLimit
  hardLimit   = each.value.hardLimit

  port_mappings      = each.value.port_mappings
  health_check_paths = each.value.health_check_paths

  ecs_container_image    = module.ecr[each.value.ecr_repo_name].ecr_url
  ecs_awslogs_group      = each.value.ecs_awslogs_group
  ecs_region             = data.aws_region.current.name
  ecs_awslogs_stream     = each.value.ecs_awslogs_stream
  cpu_architecture       = each.value.cpu_architecture
  ecs_service_name       = each.value.ecs_service_name
  ecs_service_cluster_id = module.ecs_cluster.cluster_id
  desired_count          = each.value.desired_count
  scheduling_strategy    = each.value.scheduling_strategy
  awslogs_region         = data.aws_region.current.name
  ecs_container_name     = each.value.ecs_container_name
  vpc_id                 = module.vpc.vpc_id

  ecs_service_cluster_name = each.value.ecs_service_cluster_name

  env_task_defintions = each.value.env_task_defintions

  secrets = each.value.secrets

  create_tg       = each.value.create_tg
  use_existing_tg = each.value.use_existing_tg
  existing_tg_arn = each.value.existing_tg_arn
  listener_arn    = module.load_balancer.alb_http_listener_arn //change this to https listener arn when domain available
  create_lr       = each.value.create_lr

  load_balancer_arn = module.load_balancer.alb_arn
  tg-name           = each.value.tg-name

  autoscaling_enabled = each.value.autoscaling_enabled
  max_capacity        = each.value.max_capacity
  min_capacity        = each.value.min_capacity

  is_internal_service = each.value.is_internal_service

  ## service_discovery_private_dns_id argument will be uncommented only if we are having atleast one internal service. 
  ## Otherwise for the external services it will be commented as we won't need to call the service discovery module.
  service_discovery_private_dns_id = each.value.is_internal_service ? module.service_discovery_private_dns.private_dns_name : null

  tags       = var.tags
  extra_tags = var.extra_tags

  depends_on = [module.cicd, module.ecr]
}


# ################################################################
# #                            ECS CI-CD                         #
# ################################################################
module "cicd" {
  source   = "../module/ci-cd"
  for_each = var.ecs_cicd

  ecs_service_name         = each.value.ecs_service_name
  ecs_service_cluster_name = each.value.ecs_service_cluster_name
  ecs_region               = data.aws_region.current.name

  codebuild_repo_policy_name            = each.value.codebuild_repo_policy_name
  codebuild_repo_project_description    = each.value.codebuild_repo_project_description
  codebuild_codepipeline_artifact_store = module.s3["mohit-dev-my-proj-artifact-bucket"].s3_name
  codebuild_repo_artifacts_location     = module.s3["mohit-dev-my-proj-artifact-bucket"].s3_name

  codebuild_repo_role_name       = each.value.codebuild_repo_role_name
  codebuild_repo_project_name    = each.value.codebuild_repo_project_name
  codebuild_repo_source_version  = each.value.codebuild_repo_source_version
  codebuild_repo_source_location = each.value.codebuild_repo_source_location
  codebuild_repo_artifacts_name  = each.value.codebuild_repo_artifacts_name
  branch_event_type              = each.value.branch_event_type
  branch_head_ref                = each.value.branch_head_ref
  environment_variables          = each.value.environment_variables

  codepipeline_name        = each.value.codepipeline_name // Also creates new folder for each codepipeline build & source artifacts in artifact bucket 
  codepipeline_policy_name = each.value.codepipeline_policy_name
  buildspec_file_name      = each.value.buildspec_file_name
  codepipeline_role_name   = each.value.codepipeline_role_name

  remote_party_owner      = each.value.remote_party_owner
  source_version_provider = each.value.source_version_provider
  connection_arn          = each.value.connection_arn
  remote_repo_name        = each.value.remote_repo_name
  remote_branch           = each.value.remote_branch
  remote_file_path        = each.value.remote_file_path
  deployment_timeout      = each.value.deployment_timeout
  definition_file_name    = each.value.definition_file_name

  tags       = var.tags
  extra_tags = var.extra_tags

  depends_on = [module.ecr, module.s3]
}

# ################################################################
# #                            EC2-Bastion                       #
# ################################################################

module "ec2_instances" {
  source = "../module/ec2"

  for_each = local.ec2_instances // Look for EC2 section in local.tf

  ec2_instance_name         = each.value.ec2_instance_name // Add ec2 instance name
  instance_type             = each.value.instance_type     // Add ec2 instance type
  key_pair_name             = each.value.key_pair_name     //Create ssh key-pair using console
  iam_instance_profile      = each.value.iam_instance_profile
  subnet_id                 = each.value.subnet_id
  vpc_security_group_ids    = each.value.vpc_security_group_ids
  root_block_device_details = each.value.root_block_device
  spot_instance_details     = each.value.spot_instance_details
  user_data_script          = each.value.user_data_script
  number_of_instances       = each.value.number_of_instances
  tags                      = var.tags
  extra_tags                = var.extra_tags
}


module "service_discovery_private_dns" {
  source = "../module/servicediscovery"

  vpc_id                   = module.vpc.vpc_id
  is_internal_service      = true // providing value here because it will be created only one time.
  ecs_service_cluster_name = module.ecs_cluster.cluster_name
}