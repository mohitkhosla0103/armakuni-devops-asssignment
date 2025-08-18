
# Security Group

## Overview

This Terraform module creates AWS Security Groups, which act as virtual firewalls to control inbound and outbound traffic for your instances within a Virtual Private Cloud (VPC). Security Groups operate at the instance level, allowing you to define rules that control traffic to and from your instances.


## Table of Contents

- [Prerequisites](#prerequisites)
- [Inputs](#inputs)
- [Module Usage](#module-usage)

## Prerequisites

Before using this Terraform module, ensure you have the following prerequisites installed on your machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

## Inputs

| Name           | Type          | Default      | Mandatory | Description                                                  |
|----------------|---------------|--------------|-----------|--------------------------------------------------------------|
| sg_name        | string        |              | Yes       | Name for the Security Group.                                  |
| description    | string        |   ""          | No        | Description for the Security Group.                           |
| vpc_id         | string        |              | Yes       | VPC ID to associate the Security Group with.                 |
| ingress_rules  | list(object)   |            | Yes       | List of ingress rules to define for the Security Group.For more information refer this https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group      |
| egress_rules   | list(object)   |            | Yes       | List of egress rules to define for the Security Group.       |



## Module Usage

```hcl
module "security_group" {
  source        = "../modules/security-groups"
  for_each      = var.security_groups
                                   // this is the example how you can create sg.
  security_groups = {
  "sg1" = {
    name        = "aws-rds-sg"
    description = "RDS sg"
    ingress_rules = [
      {
        from_port       = 5432
        to_port         = 5432
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        description     = "Allow Postgres"
        security_groups = []
      },
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        description     = "Allow All for ECS"
        security_groups = [] 
      },
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["10.0.0.0/16"]
        description     = "Allow All for VPC"
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
      Name        = "aws-rds-sg"
      Environment = "production"
      project     = "aws-project"
    }
  }
}
}
```
