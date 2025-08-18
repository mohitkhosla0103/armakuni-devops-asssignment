
# VPC

## Overview

This Terraform module creates an AWS Virtual Private Cloud (VPC), providing a logically isolated section of the AWS Cloud where you can launch AWS resources. A VPC can span multiple Availability Zones, enabling high availability and fault tolerance for your applications.


## Table of Contents

- [Prerequisites](#prerequisites)
- [Inputs](#inputs)
- [Module Usage](#module-usage)

## Prerequisites

Before using this Terraform module, ensure you have the following prerequisites installed on your machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

## Inputs

| Name         | Type         | Default       | Mandatory | Description                                              |
|--------------|--------------|---------------|-----------|----------------------------------------------------------|
| cidr_block   | string       |               | Yes       | CIDR block for the VPC.For more information refer this https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc                                   |
| vpc_name     | string       |               | Yes       | Name for the VPC.                                        |
| tags         | map(string)  | { Environment = Production}            | No       | Tags to be applied to the VPC for better organization.    |
| extra_tags   | map(string)  | {}            | No        | Additional tags for the VPC. Can be used for custom metadata. |



## Module Usage

```hcl
module "vpc" {
  source = "../modules/vpc"

  vpc-name = aws-vpc
  cidr_block = "10.0.0.0/16"

  tags = {
    Environment = Production
    }

  extra_tags = {
    Project = Aws-project
}
}
```
