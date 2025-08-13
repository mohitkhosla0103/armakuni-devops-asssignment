# Terraform AWS CloudWatch Dashboard Module

## Overview

This Terraform module creates an AWS CloudWatch dashboard with customizable configurations for monitoring various metrics associated with AWS resources such as ALB, EC2, RDS, and S3. The dashboard is composed of several widgets defined in JSON files, which are loaded dynamically by the module.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Inputs](#inputs)
- [Module Usage](#module-usage)
- [Examples](#examples)

## Prerequisites

Before using these Terraform modules, ensure you have the following prerequisites installed on your machine:
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- Enable Custom Metrics in ec2 if you want to add graph for EC2 Custom metrics like memory, disk used percentage, etc. [details](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)

## Inputs

| Name                  | Type       | Default            | Mandatory | Description                                            |
|-------------------------|-------------|---------------------|-----------|-----------------------------------------------------------|
| widget_files           | list(string)|                  | Yes      | List of paths to the JSON files for the widgets              |
| dashboard_name         | string     |                   | Yes      | Name of the CloudWatch dashboard                           |

The `widget_files` variable is a list of paths to the JSON files that define the widgets for the dashboard. Each JSON file should contain the configuration for one widget. The `dashboard_name` variable is the name of the CloudWatch dashboard that will be created.

## Module Usage

Here is an example of how to use this module:
```
module "cloudwatch_dashboard" {
 source = "path/to/module"

 # Customize all variables based on your requirements
 widget_files = ["./ALB/alb_4XX_error_widget.json", "./EC2/ec2_cpu_widget.json"]
 dashboard_name = "MyDashboard"
}
```

In this example, two widgets are added to the dashboard: one for tracking 4xx errors on the load balancers, and another for tracking EC2 CPU Metrics.

Remember to replace `"path/to/module"` with the actual path to the module. Also, the paths to the widget files should be relative to the root directory where you run `terraform apply`.

Please note that the JSON files for the widgets should follow the AWS CloudWatch dashboard widget specification. You can find more details about this in the [AWS documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/CloudWatch-Dashboard-Body-Structure.html).

## Examples

```
{
    "type": "metric",
    "x": 0,
    "y": 0,
    "width": 12,
    "height": 6,
    "properties": {
      "metrics": [
        ["AWS/EC2", "CPUUtilization", "InstanceId", "your-instance-id-1"],
        ["AWS/EC2", "CPUUtilization", "InstanceId", "your-instance-id-2"],
        ["AWS/EC2", "CPUUtilization", "InstanceId", "your-instance-id-3"]
      ],
      "period": 300,
      "stat": "Average",
      "region": "us-east-1",
      "title": "EC2 Instance CPU",
      "view": "timeSeries"
    }
   }

```

In the previous example, replace your-instance-id-1/2/3 with your actual instance IDs. You can add multiple instances in a single widget by specifying the instance IDs separated by commas in metrics.

Additionally, you can modify other variables such as the title of the widget and the region. For more details, refer to the [AWS official documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/CloudWatch-Dashboard-Body-Structure.html).
 
You can also find examples of the JSON files for the widgets in the `.examples` directory of this repository. Each subdirectory corresponds to a different AWS service, and contains JSON files for different types of widgets related to that service.

Notes: 
- Modify the values in the JSON according to your specific requirements.
- To configure the ALB service, you need to extract the load balancer ARN starting from "app/name/id" and use it as the load balancer name parameter.