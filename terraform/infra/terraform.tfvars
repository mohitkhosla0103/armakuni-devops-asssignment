

tags = {
}

extra_tags = {
  Project          = "mohit-poc",
  Environment      = "dev",
  TerraformManaged = true // Add tags here

}


#################################################################
#                          Networking                           #
#################################################################


vpc_cidr              = "10.0.0.0/16" // Change CIDR Range
vpc_name              = "mohit-dev-vpc"
eip_name              = "mohit-dev-nat-elastic-ip"
nat_gateway_name      = "mohit-dev-nat-gateway"
internet_gateway_name = "mohit-dev-igw"
pub_route_table_name  = "mohit-dev-pub-route-table"
priv_route_table_name = "mohit-dev-pvt-route-table"
pub_route_dest_cidr   = "0.0.0.0/0"
priv_route_dest_cidr  = "0.0.0.0/0"



# # #################################################################
# # #                          Loadbalancer                         #
# # #################################################################


alb_name         = "mohit-dev-loadblancer"
is_alb_internal  = false
alb_idle_timeout = 60



# #################################################################
# #                          ECR                                  #
# #################################################################
repositories = {
  "mohit-dev-backend-mohit-dev-repo" = {
    name                 = "mohit-dev-backend-poc-repo"
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
  "mohit-dev-my-proj-artifact-bucket" = {
    bucket            = "mohit-dev-my-proj-artifact-bucket" //S3 to store source & build artifcats for CI-CD
    bucket_versioning = "Enabled"
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
use_ec2_spot_instances    = true // specify true if want to create all spot instances or specify false if want to create all on-demand instances
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
    ecr_repo_name            = "mohit-dev-backend-poc-repo" //ECR repo name

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
      3000 = "/healthz"

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
      IMAGE_REPO_NAME      = "mohit-dev-backend-poc-repo" //Add ECR repo name
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
    codebuild_repo_source_version      = "main" //Add branch name
    buildspec_file_name                = "buildspec.yml"
    codebuild_repo_source_location     = "https://github.com/mohitkhosla0103/armakuni-devops-asssignment" //Entire Repo URL for e.g (https://github.com/ak-test-organisation/ak-test)
    codebuild_repo_artifacts_name      = "dev-backend-codebuild-artifact"
    branch_event_type                  = "PUSH"
    branch_head_ref                    = "ref/heads/main" //Add branch name

    codepipeline_name        = "dev-backend-codepipeline" //Source & Build artifacts are stored in folder (folder name is same as pipeline name) in artifact s3 bucket that we created earlier        
    codepipeline_policy_name = "dev-backend-codepipeline-policy"
    codepipeline_role_name   = "dev-backend-codepipeline-role"
    remote_party_owner       = "ThirdParty"
    source_version_provider  = "GitHub"                                                                                         //Enter Source version provider
    connection_arn           = "arn:aws:codeconnections:us-east-1:222634373323:connection/df31bb54-b8bb-4331-bbfe-8235483f27c6" //Enter ARN of Codestar Connection that we created using console
    remote_repo_name         = "mohitkhosla0103/armakuni-devops-asssignment"                                                    //Enter Organization/repo-name  for e.g (ak-test-organisation/ak-test)
    remote_branch            = "main"                                                                                           //Add branch name
    remote_file_path         = ""
    deployment_timeout       = 25
    definition_file_name     = "imagedefinitions.json"
  }
}

