
# AWS Subnet Module

## Overview

This Terraform module creates AWS Subnets within a Virtual Private Cloud (VPC), providing segmentation of network resources. Subnets are associated with a specific availability zone and play a crucial role in organizing and isolating resources within a VPC.


## Table of Contents

- [Prerequisites](#prerequisites)
- [Inputs](#inputs)
- [Module Usage](#module-usage)

## Prerequisites

Before using this Terraform module, ensure you have the following prerequisites installed on your machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

## Inputs

| Name               | Type         | Default           | Mandatory | Description                                                  |
|--------------------|--------------|-------------------|-----------|--------------------------------------------------------------|
| subnet_name        | string       |                  | Yes       | Name for the Subnet.                                         |
| cidr_block         | string       |                   | Yes       | CIDR block for the Subnet.For more information refer this https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet                                    |
| availability_zone  | string       |     "us-east-1a"              | No       | Availability Zone for the Subnet.                            |
| vpc_id             | string       |                   | Yes       | VPC ID to associate the Subnet with.                         |
| tags               | map(string)  | {}                | No        | Tags to be applied to the Subnet for better organization.    |
| extra_tags         | map(string)  | {}                | No        | Additional tags for the Subnet. Can be used for custom metadata. |



## Module Usage

```hcl

//please refer local.tf file for creating Subnet Module.
//To create public-subnet use same approach as private-subnet. 

module "pvt-sub" {
  source   = "../modules/subnet"
  for_each = { for pvt_subnets in flatten(local.pvt_subnets) : pvt_subnets.cidr_block => pvt_subnets }

  subnet-name       = each.value.subnet_name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  vpc_id = module.vpc.vpc_id

  tags       = local.tags
  extra_tags = local.extra_tags
}
```
