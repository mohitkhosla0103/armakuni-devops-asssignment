module "ecs" {
  source = "../module/ecs"

  cluster_name      = var.ecs_cluster_name
  capacity_provider = var.capacity_provider_name
  #ecs_asg_arn 
  maximum_scaling_step_size     = var.max_scaling_step_size
  launch_template_name          = var.ecs_template_name
  launch_template_instance_type = var.ecs_instance_type
  ebs_volume_size               = var.ecs_volume_size          // number
  ebs_volume_type               = var.ecs_instance_volume_type //gp3
  enable_encryption             = true
  tag_value                     = var.ecs_tag_value
  asg_name                      = var.ecs_asg_name
  security_group_ids            = [module.security_group["sg2"].sg_id]
  #ecs_instance_profile_role = "ecsInstanceRole"
  min_size           = var.ecs_asg_min_size     // number
  max_size           = var.ecs_asg_max_size     // number
  desired_capacity   = var.ecs_asg_desired_size // number
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = local.pvt_subnet_ids
  on_demand_capacity = var.ecs_on_demand_cap
  ecs_instance_role_name = var.ecs_instance_role_name
  instance_profile   = var.ecs_instance_profile_name
  spot_max_price     = var.spot_max_price
  key_name           = var.ecs_instance_ssh_name // Please create this before assigning
  user_data_script   = local.encoded_userdata
}
