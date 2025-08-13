
# Internet Gateway Module

## Overview

This Terraform module creates an Internet Gateway (IG) in AWS, allowing communication between your Virtual Private Cloud (VPC) and the internet. Internet Gateways serve as a key component for enabling outbound and inbound internet traffic for resources within the VPC.


## Table of Contents

- [Prerequisites](#prerequisites)
- [Inputs](#inputs)
- [Module Usage](#module-usage)

## Prerequisites

Before using this Terraform module, ensure you have the following prerequisites installed on your machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

## Inputs

| Name          | Type          | Default    | Mandatory | Description                                                       |
|---------------|---------------|------------|-----------|-------------------------------------------------------------------|
| ig_name       | string        |      | Yes       | Name for the Internet Gateway (IG). For more information refer this https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway                                |
| tags          | map(string)   | {Environment = "Production"}         | No       | Tags to be applied to the Internet Gateway. Use for standard metadata like `Environment`. |
| extra_tags    | map(string)   | {}         | No        | Additional tags for the Internet Gateway. Can be used for project-specific metadata like `Project`. |





## Module Usage

```hcl
module "internet_gateway" {
  source = "../modules/internet-gateway"

  ig-name = aws-ig
  tags = {
       Environment = "Production"
         }
  extra_tags = {
    Project = "aws-project"
          }
}
```
