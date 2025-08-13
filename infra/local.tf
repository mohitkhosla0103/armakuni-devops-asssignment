locals {
  # Define the environment based on the current workspace
  environment = terraform.workspace

  # Define a map of subnet CIDR blocks for different environments
  private_subnet_cidr = {
    "dev"  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
    "qa"= ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
    "prod" = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
    
  }
  private_subnet_az = {
    "dev" = ["us-east-1a", "us-east-1b", "us-east-1c"]
    "qa" = ["us-east-1a", "us-east-1b", "us-east-1c"]
    "prod" = ["us-east-1a", "us-east-1b", "us-east-1c"]
   
  }
  # Fetch the subnet CIDR blocks based on the current workspace
  selected_private_cidr_blocks = lookup(local.private_subnet_cidr, local.environment, [])
 
  selected_private_az = lookup(local.private_subnet_az, local.environment, [])

  # Combine subnet names and CIDR blocks into a list of maps
  pvt_subnets = [
    for i in range(length(local.selected_private_cidr_blocks)) : {
      subnet_name       = "${local.environment}-private-subnet-${i + 1}"
      cidr_block        = local.selected_private_cidr_blocks[i]
      availability_zone = local.selected_private_az[i]
    }
  ]

# Define a map of subnet CIDR blocks for different environments
  public_subnet_cidr = {
    
   
    "dev"  = ["10.0.4.0/22", "10.0.8.0/22", "10.0.12.0/22"]
    "qa" = ["10.1.4.0/22", "10.1.8.0/22", "10.1.12.0/22"]
    "prod" = ["10.2.4.0/22", "10.2.8.0/22", "10.2.12.0/22"]
     
  }
  public_subnet_az = {
    "dev" = ["us-east-1a", "us-east-1b", "us-east-1c"]
    "qa" = ["us-east-1a", "us-east-1b", "us-east-1c"]
    "prod" = ["us-east-1a", "us-east-1b", "us-east-1c"]
   
  }
  # Fetch the subnet CIDR blocks based on the current workspace
  selected_public_cidr_blocks = lookup(local.public_subnet_cidr, local.environment, [])
 
  selected_public_az = lookup(local.public_subnet_az, local.environment, [])

  # Combine subnet names and CIDR blocks into a list of maps
  pub_subnets = [
    for i in range(length(local.selected_public_cidr_blocks)) : {
      subnet_name       = "${local.environment}-public-subnet-${i + 1}"
      cidr_block        = local.selected_public_cidr_blocks[i]
      availability_zone = local.selected_public_az[i]
    }
  ]

  pub_subnet_ids = flatten([
    for subnet in module.pub-sub : subnet.id
  ])

  pvt_subnet_ids = flatten([
    for subnet in module.pvt-sub : subnet.id
  ])

  


#################################################################
#                          ECS Cluster                          #
#################################################################

  userdata_script = <<-EOT
    #!/bin/bash
    sudo yum update -y
    echo "ECS_CLUSTER=${terraform.workspace}-cluster" | sudo tee -a /etc/ecs/ecs.config
  EOT

  encoded_userdata = base64encode(local.userdata_script)



#################################################################
#                          RDS                                  #
#################################################################


  rds_creds = {
    "rds1" = jsondecode(data.aws_secretsmanager_secret_version.demo_rds_creds.secret_string),
  }


#################################################################
#                          EC2                                  #
#################################################################

  ec2_instances = {
    ec2_1 = {
      ec2_instance_name                  = "${terraform.workspace}-bastion-host"
      instance_type                     = "t2.micro"

      key_pair_name                     = "bastion-host"

      iam_instance_profile = {
        create_new_instance_profile      = false
        custom_iam_instance_profile_name = ""

        iam_role_name                 = ""
        create_inline_policy          = false
        inline_iam_policy_name        = ""
        inline_iam_policy_description = ""
        inline_policy_actions         = []
        inline_policy_resource        = ""

        attach_managed_policy = false
        managed_policy_arns   = []

        use_existing_instance_profile  = false
        existing_instance_profile_name = ""
      }

      subnet_id                        = local.pub_subnet_ids[0]
      vpc_security_group_ids           = [module.independent_security_group["${terraform.workspace}-bastion-host-sg"].sg_id]

      root_block_device = {
        volume_type                    = "gp3"
        volume_size                    = "8"
        delete_on_termination          = true
      }

      spot_instance_details            = {}

      user_data_script                 = ""

      number_of_instances              = 1
    }
  }


#################################################################
#                          Security Groups                      #
#################################################################

independent_security_group= {
    "${terraform.workspace}-loadbalancer-sg" = {
    name        = "${terraform.workspace}-loadbalancer-sg"
    description = "${terraform.workspace} loadbalancer sg"
    ingress_rules = [
      {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        //ipv6_cidr_block = ["::/0"]
        description     = "Allow all traffic"
        security_groups = [] 
      },
      {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
      // ipv6_cidr_block  =["::/0"]
        description     = "Allow all traffic"
        security_groups = [] 
      }
    ]
    egress_rules = [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        description     = "Allow all outbound traffic"
        security_groups = []
      }
    ]
    tags = {
     
    }
  },
   "${terraform.workspace}-bastion-host-sg" = {
    name        = "${terraform.workspace}-bastion-host-sg"
    description = "${terraform.workspace} bastionhost sg"
    ingress_rules = [
      {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = []
        //ipv6_cidr_block = ["::/0"]
        description     = "Allow all traffic"
        security_groups = [] 
      }
    ]
    egress_rules = [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        description     = "Allow all outbound traffic"
        security_groups = []
      }
    ]
    tags = {
     
    }
  }

}


dependent_security_group= {
  "${terraform.workspace}-autoscaling-group-sg" = {
    name        = "${terraform.workspace}-autoscaling-group-sg"
    description = "${terraform.workspace} autoscaling-group sg"
    ingress_rules = [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = []
        description     = ""
        security_groups = [module.independent_security_group["${terraform.workspace}-loadbalancer-sg"].sg_id] 
      },
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = []
        description     = ""
        security_groups = [module.independent_security_group["${terraform.workspace}-bastion-host-sg"].sg_id] 
      }
    ]
    egress_rules = [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        description     = "Allow all outbound traffic"
        security_groups = []
      }
    ]
    tags = {
     
    }
  
  },
  "${terraform.workspace}-rds-sg" = {
    name        = "${terraform.workspace}-rds-sg"
    description = "${terraform.workspace} rds sg"
    ingress_rules = [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        description     = ""
        security_groups = [] 
      }
    ]
    egress_rules = [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        description     = "Allow all outbound traffic"
        security_groups = []
      }
    ]
    tags = {
     
    }
  
  }
   
}



# ################################################################
# #                            Alarms                            #
# ################################################################




 alarm_definitions = {

    /* ----------------------------------- ALB ---------------------------------- */
    alb-4xx-errors = {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_ELB_4XX_Count"
      dimensions = {
        LoadBalancer = regex("loadbalancer/(app/[^/]+/[^/]+)", module.load_balancer.alb_arn)[0]
      }
      statistic           = "Sum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 2000
      alarm_name          = "${terraform.workspace}-alb-http-4xx-alarm"
      alarm_description   = "Alarm for ALB 4XX errors"
      evaluation_periods  = 5
      period              = 60
      actions_enabled     = true

      alarm_actions = [module.sns.sns_topic_arn]
    }
    alb-5xx-errors = {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_ELB_5XX_Count"
      dimensions = {
        LoadBalancer = regex("loadbalancer/(app/[^/]+/[^/]+)", module.load_balancer.alb_arn)[0]
      }
      statistic           = "Sum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 1000
      alarm_name          = "${terraform.workspace}-alb-http-5xx-alarm"
      alarm_description   = "Alarm for ALB 5XX errors"
      evaluation_periods  = 5
      period              = 60
      actions_enabled     = true

      alarm_actions = [module.sns.sns_topic_arn]
    }
    alb-target-4xx-errors = {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_Target_4XX_Count"
      dimensions = {
        LoadBalancer = regex("loadbalancer/(app/[^/]+/[^/]+)", module.load_balancer.alb_arn)[0]
      }
      statistic           = "Sum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 3000
      alarm_name          = "${terraform.workspace}-alb-http-target-4xx-alarm"
      alarm_description   = "Alarm for ALB target 4XX errors"
      evaluation_periods  = 5
      period              = 60
      actions_enabled     = true

      alarm_actions = [module.sns.sns_topic_arn]
    }
    alb-target-5xx-errors = {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_Target_5XX_Count"
      dimensions = {
        LoadBalancer = regex("loadbalancer/(app/[^/]+/[^/]+)", module.load_balancer.alb_arn)[0]
      }
      statistic           = "Sum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 10
      alarm_name          = "${terraform.workspace}-alb-http-target-5xx-alarm"
      alarm_description   = "Alarm for ALB target 5XX errors"
      evaluation_periods  = 5
      period              = 60
      actions_enabled     = true

      alarm_actions = [module.sns.sns_topic_arn]
    }
    alb-grpc-request-count = {
      namespace   = "AWS/ApplicationELB"
      metric_name = "GrpcRequestCount"
      dimensions = {
        LoadBalancer = regex("loadbalancer/(app/[^/]+/[^/]+)", module.load_balancer.alb_arn)[0]
      }
      statistic           = "Sum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 10
      alarm_name          = "${terraform.workspace}-alb-grpc-request-count-alarm"
      alarm_description   = "Alarm for GRPC request count errors"
      evaluation_periods  = 5
      period              = 60
      actions_enabled     = true

      alarm_actions = [module.sns.sns_topic_arn]
    }
    alb-active-connections = {
      namespace   = "AWS/ApplicationELB"
      metric_name = "ActiveConnectionCount"
      dimensions = {
        LoadBalancer = regex("loadbalancer/(app/[^/]+/[^/]+)", module.load_balancer.alb_arn)[0]
      }
      statistic           = "Sum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 500
      alarm_name          = "${terraform.workspace}-alb-active-connections-alarm"
      alarm_description   = "Alarm for active connections"
      evaluation_periods  = 5
      period              = 60
      actions_enabled     = true

      alarm_actions = [module.sns.sns_topic_arn]
    }
    alb-request-count = {
      namespace   = "AWS/ApplicationELB"
      metric_name = "RequestCount"
      dimensions = {
        LoadBalancer = regex("loadbalancer/(app/[^/]+/[^/]+)", module.load_balancer.alb_arn)[0]
      }
      statistic           = "Sum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 1000
      alarm_name          = "${terraform.workspace}-alb-request-count-alarm"
      alarm_description   = "Alarm for request count errors"
      evaluation_periods  = 5
      period              = 60
      actions_enabled     = true

      alarm_actions = [module.sns.sns_topic_arn]
    }
 }



}
