
# NAT Gateway Module 

## Overview

This Terraform module creates a Network Address Translation (NAT) Gateway in AWS, providing a scalable solution for instances in a private subnet to initiate outbound traffic to the internet. NAT Gateways are commonly used in conjunction with private subnets to allow resources within those subnets to access external services while keeping them hidden from inbound traffic.


## Table of Contents

- [Prerequisites](#prerequisites)
- [Inputs](#inputs)
- [Module Usage](#module-usage)

## Prerequisites

Before using this Terraform module, ensure you have the following prerequisites installed on your machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

## Inputs

| Name          | Type          | Default          | Mandatory | Description                                                       |
|---------------|---------------|------------------|-----------|-------------------------------------------------------------------|
| ng_name       | string        |   | Yes       | Name for the NAT Gateway.For more information refer this https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway                                         |
| tags          | map(string)   | {Environment= "production"}               |No       | Tags to be applied to the NAT Gateway. Use for standard metadata like `Environment` and `Project`. |
| extra_tags    | map(string)   | {}               | No        | Additional tags for the NAT Gateway. Can be used for custom metadata like `Owner`. |




## Module Usage

```hcl
module "natgw" {
  source = "../modules/nat-gateway"

  ng-name       = aws-nat-gateway
  allocation_id = module.eip.eip_id
  subnet_id     = local.pub_subnet_ids[0]   //refer local.tf

  tags = {
    environment = Production
    project     = AWS-Project
}

extra_tags = {
    Owner = owner-nmae
}
}
```
