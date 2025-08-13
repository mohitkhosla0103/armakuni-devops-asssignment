
# AWS Route Table Module

## Overview

This Terraform module creates an AWS Route Table, which is used to define routes for network traffic leaving a subnet in a Virtual Private Cloud (VPC). A route table contains a set of rules, called routes, that are used to determine where network traffic is directed.


## Table of Contents

- [Prerequisites](#prerequisites)
- [Inputs](#inputs)
- [Module Usage](#module-usage)

## Prerequisites

Before using this Terraform module, ensure you have the following prerequisites installed on your machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

## Inputs

| Name         | Type          | Default        | Mandatory | Description                                                       |
|--------------|---------------|----------------|-----------|-------------------------------------------------------------------|
| rt_name      | string        |  | Yes       | Name for the Public Route Table.                                   |
| vpc_id       | string        |                | Yes       | VPC ID to associate the Public Route Table with.For more information refer this https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table                  |
| subnet_ids   | list(string)  |              | Yes       | List of subnet IDs to associate with the Public Route Table.      |
| tags         | map(string)   | {}             | No       | Tags to be applied to the Public Route Table.                     |
| extra_tags   | map(string)   | {}             | No        | Additional tags for the Public Route Table. Can be used for custom metadata. |



## Module Usage

```hcl
module "pub_route_table" {
  source = "../modules/route-table"

  rt-name = aws-route-table
  vpc_id  = module.vpc.vpc_id 


  subnet_ids = concat(local.pub_subnet_ids)        //refer local.tf file 
  
  tags = {
    Environment = "Production"
}
  extra_tags = {
    Project = "aws-Project"
}
}
```
