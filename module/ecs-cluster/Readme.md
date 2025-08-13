
# Terraform ECS Module

## Overview

This Terraform module simplifies the deployment of an Amazon ECS (Elastic Container Service) cluster, allowing for easy customization of configurations. It streamlines the process of setting up and managing ECS instances for your containerized applications in a modular and configurable manner.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Inputs](#inputs)
- [Module Usage](#module-usage)

## Prerequisites

Before using this Terraform module, ensure you have the following prerequisites installed on your machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

## Inputs

| Name                           | Type           | Default                    | Mandatory | Description                                                      |
|--------------------------------|----------------|----------------------------|-----------|------------------------------------------------------------------|
| ecs_cluster_name               | string         |                           | Yes       | The name of the ECS cluster.                                     |
| capacity_provider_name         | string         |                           | Yes       | The name of the ECS capacity provider. For Enter the value refer this https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers                           |
| max_scaling_step_size          | string         | "1"                         | No       | The maximum scaling step size for the Auto Scaling Group.        |
| ecs_template_name              | string         |                         | Yes       | The name of the ECS launch template. For Enter the value refer this https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers                            |
| ecs_instance_type              | string         |   "t3.medium"                      | No       | The type of EC2 instance to use.                                 |
| ecs_volume_size                | number         | 30                         | No      | The size of the EBS volume in GB.                                |
| ecs_instance_volume_type       | string         |  "gp3"                         | No       | The type of the EBS volume.                                      |
| enable_encryption              | bool           |   false                      | No       | Enable EBS volume encryption.                                    |
| ecs_tag_value                  | string         |   "enter-environment"                        | No       | Tag value for ECS resources.                                     |
| ecs_asg_name                   | string         |                           | Yes       | Name of the Auto Scaling Group.                                  |
| ecs_asg_min_size               | number         | 1                          | No       | Minimum size of the Auto Scaling Group.                          |
| ecs_asg_max_size               | number         | 2                          | No       | Maximum size of the Auto Scaling Group.                          |
| ecs_asg_desired_size           | number         | 1                          | No       | Desired size of the Auto Scaling Group.                          |
| vpc_id                         | string         |                           | Yes       | ID of the VPC.                                                   |
| subnet_ids                     | list(string)   |                          | Yes       | List of subnet IDs.                                              |
| on_demand_capacity             | number         |                           | Yes       | Number of on-demand instances needed (0 means all instances will be spot). |
| ecs_instance_role_name         | string         |                           | Yes       | Name of the ECS instance role.                                   |
| instance_profile               | string         |                           | Yes       | Name of the ECS instance profile.                               |
| spot_max_price                 | string         | -                          | No      | Maximum price for spot instances in USD.                        |
| ecs_instance_ssh_name          | string         | ""                          | No       | Name of the SSH key pair for EC2 instances. For enter the value refer this https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster                   |


## Module Usage

```hcl
module "ecs" {
  source = "../module/ecs"

  # Required Variables
  cluster_name                = "aws-ecs-cluster"
  capacity_provider           = "aws-ecs-capacity-provider"
  max_scaling_step_size        = "1"
  ecs_template_name           = "aws_template"
  ecs_instance_type           = "t3.medium"
  ecs_volume_size             = 30
  ecs_instance_volume_type    = "gp3"
  enable_encryption           = true
  ecs_tag_value               = "enter-environment"
  ecs_asg_name                = "aws_asg"
  ecs_asg_min_size            = 1
  ecs_asg_max_size            = 2
  ecs_asg_desired_size        = 1
  vpc_id                      = "vpc-12345678"
  subnet_ids                  = ["subnet-abcdef01", "subnet-01234567"]
  on_demand_capacity          = 0
  ecs_instance_role_name      = "enter-desired-value-ecsInstanceRole"
  instance_profile            = "enter-desired-value-ecsInstanceProfile"
  spot_max_price              = "spot-price-per-hour-USD"
  ecs_instance_ssh_name       = "enter-desired-value-ssh"
  # ... (add any additional optional variables as needed)
}

```

