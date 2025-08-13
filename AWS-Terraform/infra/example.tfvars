# For new envionment - 
# 1 - Create new worspace with same name as new env
# 2 - Add private_subnet_cidr,private_subnet_az,public_subnet_cidr & public_subnet_cidr for new env in local.tf






tags = {

}

extra_tags = {
  Project          = "Aurora-Module",
  Environment      = "poc",
  TerraformManaged = true // Add tags here

}


#################################################################
#                          Networking                           #
#################################################################


vpc_cidr              = "10.0.0.0/16" // Change CIDR Range
vpc_name              = "dev-vpc"
eip_name              = "dev-nat-elastic-ip"
nat_gateway_name      = "dev-nat-gateway"
internet_gateway_name = "dev-igw"
pub_route_table_name  = "dev-pub-route-table"
priv_route_table_name = "dev-pvt-route-table"
pub_route_dest_cidr   = "0.0.0.0/0"
priv_route_dest_cidr  = "0.0.0.0/0"



# # #################################################################
# # #                          Loadbalancer                         #
# # #################################################################


alb_name         = "dev-loadblancer"
is_alb_internal  = false
alb_idle_timeout = 60



# #################################################################
# #                          ECR                                  #
# #################################################################
repositories = {
  "dev-backend-poc-repo" = {
    name                 = "dev-backend-poc-repo"
    image_tag_mutability = "MUTABLE"
    scan_on_push         = true
    tags = {

    }
  }

}


# #################################################################
# #                          S3                                   #
# #################################################################

s3_bucket = {
  "dev-my-proj-artifact-bucket" = {
    bucket            = "dev-my-proj-artifact-bucket" //S3 to store source & build artifcats for CI-CD
    bucket_versioning = "Enabled"
  },
  "dev-domain-cloudfront-bucket" = {
    bucket            = "dev-domain-cloudfront" //S3 for cloudfront
    bucket_versioning = "Enabled"
  }
}


# #################################################################
# #                          Cloudfront                            #
# #################################################################
cloudfront = {
  "dev-domain-cloudfront" = {
    bucket_domain_name = "dev-domain-cloudfront.s3.us-east-1.amazonaws.com"

  }
}


# ################################################################
# #                             ECS  Cluster                     #
# ################################################################
cluster_type     = "FARGATE"     // value of cluster_type can be FARGATE or EC2.
ecs_cluster_name = "dev-cluster" //cluster-name should be in format ("terraform.workspace-cluster") or you can change format for all envs(see ecs cluster in local.tf)

//below values does not have any part in Fargate cluster (cannot have null values)
capacity_provider_name    = "dev-capacity-provider"
max_scaling_step_size     = "1"
ecs_template_name         = "dev-autoscaling-template"
ecs_instance_type         = "t3.small"
ecs_volume_size           = 30
ecs_instance_volume_type  = "gp3"
enable_encryption         = true
ecs_tag_value             = "dev"
ecs_asg_name              = "dev-autoscaling-group"
use_ec2_spot_instances    = true                            // specify true if want to create all spot instances or specify false if want to create all on-demand instances
ecs_asg_min_size          = 1
ecs_asg_max_size          = 2
ecs_asg_desired_size      = 1
ecs_instance_role_name    = "dev-autoscaling-group-ecsInstanceRole"
ecs_instance_profile_name = "dev-autoscaling-group-ecsInstanceProfile"
ecs_instance_ssh_name     = "dev-autoscaling-group-ssh-key" //Create ssh key-pair using console




# #################################################################
# #                          ECS Service                          #
# #################################################################



ecs_service = {
  ## ecs with ec2 service variables
  backend-service = {
    container_runtime = "EC2" // value of container_runtime can be FARGATE or EC2.   
    ecs_task_role     = "dev-backend-task-role"
    ecs_service_role  = "dev-backend-service-role"

    listener_rule_priority = 1 // Must be unique for each service

    health_check_interval = 30
    health_check_timeout  = 5
    healthy_threshold     = 5
    unhealthy_threshold   = 2

    ecs_task_family          = "dev-backend-task-definition"
    network_mode             = "bridge"
    requires_compatibilities = ["EC2"]
    task_cpu                 = 256
    task_memory              = 512
    cpu                      = 256
    softLimit                = 256
    hardLimit                = 512
    ecr_repo_name            = "dev-backend-poc-repo" //ECR repo name

    port_mappings = [
      {
        containerPort = 3000
        hostPort      = "0"
        protocol      = "tcp"
        name          = "3000"
        path_pattern  = "/"
        host_header   = ""
      }
    ]
    health_check_paths = {
      3000 = ""

    }

    ecs_awslogs_group                      = "/ecs/dev-awslog-group-backend"
    ecs_awslogs_stream                     = "ecs"
    cpu_architecture                       = "X86_64"
    ecs_service_name                       = "dev-backend-service"
    desired_count                          = 1
    scheduling_strategy                    = "REPLICA"
    ecs_container_name                     = "dev-backend"
    ecs_service_cluster_name               = "dev-cluster"
    ecs_secrets_access_policy              = "dev-ecs-backend-secrets-access-policy"
    ecs_secrets_access_policy_resource_arn = "*" //Create secret using console & mention its arn

    attach_load_balancer = true
    is_internal_service  = false

    create_tg       = true
    use_existing_tg = false
    existing_tg_arn = ""
    create_lr       = true
    tg-name         = "dev-backend-tg"

    autoscaling_enabled = true
    max_capacity        = 2
    min_capacity        = 1

    env_task_defintions = []
    secrets             = []

  }

  ## ecs with fargate variables example
  backend-service = {
    container_runtime = "FARGATE" // value of container_runtime can be FARGATE or EC2.   
    ecs_task_role     = "dev-backend-task-role"
    ecs_service_role  = "dev-backend-service-role"

    listener_rule_priority = 1 // Must be unique for each service

    health_check_interval = 30
    health_check_timeout  = 5
    healthy_threshold     = 5
    unhealthy_threshold   = 2

    ecs_task_family          = "dev-backend-task-definition"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    task_cpu                 = 256
    task_memory              = 512
    cpu                      = 256
    softLimit                = 256
    hardLimit                = 512
    ecr_repo_name            = "dev-backend-poc-repo" //ECR repo name

    port_mappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
        name          = "3000"
        path_pattern  = "/"
        host_header   = ""
      }
    ]
    health_check_paths = {
      3000 = ""

    }

    ecs_awslogs_group                      = "/ecs/dev-awslog-group-backend"
    ecs_awslogs_stream                     = "ecs"
    cpu_architecture                       = "X86_64"
    ecs_service_name                       = "dev-backend-service"
    desired_count                          = 1
    scheduling_strategy                    = "REPLICA"
    ecs_container_name                     = "dev-backend"
    ecs_service_cluster_name               = "dev-cluster"
    ecs_secrets_access_policy              = "dev-ecs-backend-secrets-access-policy"
    ecs_secrets_access_policy_resource_arn = "*" //Create secret using console & mention its arn

    attach_load_balancer = true
    is_internal_service  = false

    create_tg       = true
    use_existing_tg = false
    existing_tg_arn = ""
    create_lr       = true
    tg-name         = "dev-backend-tg"

    autoscaling_enabled = true
    max_capacity        = 2
    min_capacity        = 1

    env_task_defintions = []
    secrets             = []

  }

  ## internal service variables example for ecs with ec2 
  backend-internal-service = {
    container_runtime      = "EC2" // value of container_runtime can be FARGATE or EC2.   
    ecs_task_role          = "dev-backend-internal-service-task-role"
    ecs_service_role       = "dev-backend-internal-service-role"
    listener_rule_priority = 1 // Must be unique for each service

    health_check_interval = 30
    health_check_timeout  = 5
    healthy_threshold     = 5
    unhealthy_threshold   = 2

    ecs_task_family          = "dev-backend-internal-service-task-definition"
    network_mode             = "awsvpc"
    requires_compatibilities = ["EC2"]
    task_cpu                 = 256
    task_memory              = 512
    cpu                      = 256
    softLimit                = 256
    hardLimit                = 512
    ecr_repo_name            = "dev-backend-node-repo" //ECR repo name

    port_mappings = [
      {
        containerPort = 3000 // container port and hostport should be same for awsvpc nework_mode
        hostPort      = 3000
        protocol      = "tcp"
        name          = "3000"
        path_pattern  = "/"
        host_header   = ""
      }
    ]
    health_check_paths = {
      3000 = ""

    }

    ecs_awslogs_group                      = "/ecs/dev-awslog-group-backend-internal"
    ecs_awslogs_stream                     = "ecs"
    cpu_architecture                       = "X86_64"
    ecs_service_name                       = "dev-backend-internal-service"
    desired_count                          = 1
    scheduling_strategy                    = "REPLICA"
    ecs_container_name                     = "dev-backend-internal"
    ecs_service_cluster_name               = "dev-cluster"
    ecs_secrets_access_policy              = "dev-ecs-backend-internal-secrets-access-policy"
    ecs_secrets_access_policy_resource_arn = "*" //Create secret using console & mention its arn

    attach_load_balancer = false
    is_internal_service  = true
    create_tg            = false
    use_existing_tg      = false
    existing_tg_arn      = ""
    create_lr            = false
    tg-name              = ""

    autoscaling_enabled = true
    max_capacity        = 2
    min_capacity        = 1

    env_task_defintions = []
    secrets             = []

  }

}
# ################################################################
# #                            ECS CI-CD                         #
# ################################################################

ecs_cicd = {
  cicd1 = {
    ecs_service_cluster_name = "dev-cluster"         //Add cluster name 
    ecs_service_name         = "dev-backend-service" //Add service name for which CI-CD is to be created

    environment_variables = {

      AWS_DEFAULT_REGION   = "us-east-1"
      AWS_ACCOUNT_ID       = "222634373323"
      IMAGE_REPO_NAME      = "dev-backend-poc-repo" //Add ECR repo name
      IMAGE_TAG            = "latest"
      CONTAINER_NAME       = "dev-backend" // Add container name
      SECRET_NAME          = "dev-backend-env-secrets"
      PARAMETER_STORE_NAME = "Sample"
      DOCKER_PLATFORM      = "linux/amd64"
    }

    codebuild_repo_policy_name         = "dev-backend-codebuild-policy"
    codebuild_repo_project_description = "CodeBuild project for backend"
    codebuild_repo_role_name           = "dev-backend-codebuild-role"
    codebuild_repo_project_name        = "dev-backend-codebuild-project"
    codebuild_repo_source_version      = "<BRANCH_NAME>" //Add branch name
    buildspec_file_name                = "buildspec.yml"
    codebuild_repo_source_location     = "<REPO_URL>" //Entire Repo URL for e.g (https://github.com/ak-test-organisation/ak-test)
    codebuild_repo_artifacts_name      = "dev-backend-codebuild-artifact"
    branch_event_type                  = "PUSH"
    branch_head_ref                    = "ref/heads/<BRANCH_NAME>" //Add branch name

    codepipeline_name        = "dev-backend-codepipeline" //Source & Build artifacts are stored in folder (folder name is same as pipeline name) in artifact s3 bucket that we created earlier        
    codepipeline_policy_name = "dev-backend-codepipeline-policy"
    codepipeline_role_name   = "dev-backend-codepipeline-role"
    remote_party_owner       = "ThirdParty"
    source_version_provider  = "GitHub"                          //Enter Source version provider
    connection_arn           = "<CODESTAR_COnnection>"           //Enter ARN of Codestar Connection that we created using console
    remote_repo_name         = "<GITHUB_ORG>/<GITHUB_REPO_NAME>" //Enter Organization/repo-name  for e.g (ak-test-organisation/ak-test)
    remote_branch            = "<BRANCH_NAME>"                   //Add branch name
    remote_file_path         = ""
    deployment_timeout       = 25
    definition_file_name     = "imagedefinitions.json"
  }
}


# ################################################################
# #                            SNS                               #
# ################################################################

isFifo = false
name   = "dev-alarm-sns"
emails = ["<EMAIL-ID>"] //Add email-id where notifications should be sent


# ################################################################
# #                            Alarms                            #
# ################################################################
#------------------------------Budget Alarm-------------------------#
budget_name                = "dev-aws-budget-alarm"
budget_amount              = 3000.00
time_period_start          = "2024-07-01_00:00"
time_period_end            = "2024-12-31_00:00"
time_unit                  = "MONTHLY"
subscriber_email_addresses = ["<EMAIL-ID>"] //Add email-id where notifications should be sent
comparison_operator        = "GREATER_THAN"
threshold_values           = [85, 100]
notification_type          = "FORECASTED"



# ################################################################
# #                     Cloudwatch Dashboards                    #
# ################################################################

dashboard_name = "dev-dashboard"
widget_files = ["../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/EC2/ec2_cpu_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/EC2/ec2_memory_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/EC2/ec2_disc_usage_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/RDS/rds_cpu_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/RDS/rds_dbconnections_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/RDS/rds_memory_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/RDS/rds_replica_lag_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/RDS/rds_read_iops_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/RDS/rds_write_iops_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/ALB/alb_connections_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/ALB/alb_5XX_error_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/ALB/alb_4XX_error_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/ALB/alb_4xx_target_error_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/ALB/alb_5xx_target_error_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/ALB/alb_grpc_req_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/ALB/alb_total_req_widget.json",
  "../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/S3/s3_object_count.json",
"../module/cloudwatch_analytics/dashboard/Cloudwatch-Dashboard-Jsons/S3/s3_bucket_size_widget.json"]


# ################################################################
# #                            RDS                               #
# ################################################################

##################       NOTE- Check for rds creds in local.tf under RDS section      ########################################

rds_instances = {
  "rds1" = {
    rds_app_name                     = "dev-rds"
    rds_environment                  = "dev"
    rds_department                   = "dev"
    rds_allocated_storage            = 40
    rds_max_allocated_storage        = 400
    rds_db_engine                    = "postgres"
    rds_db_engine_version            = "16.3"
    rds_instance_class               = "db.t3.small"
    rds_skip_final_snapshot          = false // keep false
    rds_multi_az                     = false
    rds_performance_insights_enabled = false
    rds_publicly_accessible          = false
    rds_deletion_protection          = true // keep true
    rds_storage_type                 = "gp3"
    rds_backup_retention_period      = 7
    rds_db_name                      = "dev_rds"
  }
}


# ################################################################
# #                            Aurora Global Cluster             #
# ################################################################

create_global_cluster                             = true
rds_global_cluster_identifier                     = "dev-global-cluster"
aurora_engine                                     = "aurora-postgresql"
aurora_engine_version                             = "16.6"
skip_final_snapshot                               = false
aurora_cluster_copy_tags_to_snapshot              = true
aurora_port                                       = "5432"
aurora_cluster_parameter_group_family             = "aurora-postgresql16"
db_parameter_group_family                         = "aurora-postgresql16"
aurora_serverless_min_acu_capacity                = "0.5"
aurora_serverless_max_acu_capacity                = "1"
aurora_deletion_protection                        = true
aurora_cluster_engine_mode                        = "provisioned"          //for serverless change db class in db instances to "db.serverless"                         
cluster_backtrack_window                          = "0"
cluster_major_version_upgrade                     = false
aurora_storage_type                               = ""                               //select "" if want standard, select "aurora-iopt1" for aurora-I/O optimized 
aurora_storage_encrypted                          = true
cluster_backup_retention_period                   = "7"
aurora_min_read_replicas                          = "1"
aurora_max_read_replicas                          = "2"
aurora_target_metric_type                         = "RDSReaderAverageCPUUtilization"   //mostly used
aurora_autoscaling_threshold_cpu                  = "75"              //percentage
auroa_read_replica_scale_in_cooldown_period       = "300"             //period in seconds
aurora_read_replica_scale_out_cooldown_period     = "300"             //periodes in seconds
aurora_read_replica_autoscaling_policy_name       = "75%-autoscaling-policy"

//primary & secondary cluster details
primary_aurora_cluster_identifier                 = "dev-primary-aurora"
primary_db_cluster_preferred_backup_window        = "06:00-08:00"    
primary_db_cluster_preferred_maintenance_window   = "sun:01:00-sun:02:00"

secondary_aurora_cluster_identifier               = "dev-secondary-aurora"
secondary_db_cluster_preferred_backup_window      = "04:00-06:00"
secondary_db_cluster_preferred_maintenance_window = "sun:02:00-sun:03:00"


#Note : For Aurora Global Cluster, burstable classes instances are not supported 
primary_instance_details={
      "primary-instance-1" ={
        instance_class                      = "db.serverless"
      apply_immediately                     = true
      availability_zone                     = ""
      auto_minor_version_upgrade            = false
      db_instance_copy_tags_to_snapshot     = true
      monitoring_interval                   = 0
      performance_insights_enabled          = true
      performance_insights_kms_key_id       = ""
      performance_insights_retention_period = 7
      db_instance_preferred_maintenance_window = "sun:02:00-sun:03:00"
      promotion_tier                        = 1
      publicly_accessible               = false
      },
      "primary-instance-2" ={
     
      instance_class                        = "db.serverless"
      apply_immediately                     = true
      availability_zone                     = ""
      auto_minor_version_upgrade            = false
      db_instance_copy_tags_to_snapshot     = true
      monitoring_interval                   = 0
      performance_insights_enabled          = true
      performance_insights_kms_key_id       = ""
      performance_insights_retention_period = 7
      db_instance_preferred_maintenance_window = "sun:03:00-sun:04:00"
      promotion_tier                        = 0
      publicly_accessible                = false
      }
}

secondary_instance_details={
     "secondary-instance-1" ={
        instance_class                      = "db.serverless"
      apply_immediately                     = true
      availability_zone                     = ""
      auto_minor_version_upgrade            = false
      db_instance_copy_tags_to_snapshot     = true
      monitoring_interval                   = 0
      performance_insights_enabled          = true
      performance_insights_kms_key_id       = ""
      performance_insights_retention_period = 7
      db_instance_preferred_maintenance_window = "sun:04:00-sun:05:00"
      promotion_tier                        = 1
      publicly_accessible               = false

     }
}


# ################################################################
# #                            Secret Manager                    #
# ################################################################
secret_name = "mtlm-pinpoint-rds-creds"
secret_type = "username_password"
username = "postgresql"

# Pinpoint App Module Variables
pinpoint_app_name = "Mtlead-pinpoint-app"