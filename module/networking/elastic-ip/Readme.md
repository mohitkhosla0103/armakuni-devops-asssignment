
# Elastic-ip

## Overview

This Terraform module creates an Elastic IP (EIP) in AWS, providing a static IPv4 address that you can associate with an Amazon EC2 instance or a Network Load Balancer (NLB). Elastic IPs are particularly useful for scenarios where you need a persistent public IP address for your resources.


## Table of Contents

- [Prerequisites](#prerequisites)
- [Inputs](#inputs)
- [Module Usage](#module-usage)

## Prerequisites

Before using this Terraform module, ensure you have the following prerequisites installed on your machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

## Inputs

| Name          | Type          | Default       | Mandatory | Description                                                       |
|---------------|---------------|---------------|-----------|-------------------------------------------------------------------|
| eip_name      | string        |        | Yes       | Name for the Elastic IP (EIP). For more information refer this https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip                                     |
| tags          | map(string)   | {Environment= "production"}            | No       | Tags to be applied to the Elastic IP. Use for standard metadata like `Environment`. |
| extra_tags    | map(string)   | {}            | No        | Additional tags for the Elastic IP. Can be used for project-specific metadata like `Project`. |





## Module Usage

```hcl
module "eip" {
  source = "../modules/elastic-ip"
  eip-name = aws-eip
  tags = {
      Environment = Production
         }
  extra_tags = {
    Project = Aws-project
}
}
```
