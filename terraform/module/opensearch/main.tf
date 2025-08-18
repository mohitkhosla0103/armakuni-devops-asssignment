resource "aws_opensearch_domain" "opensearch_domain" {
  domain_name = var.domain_name
  auto_tune_options {
    # desired_state = "ENABLED"
    desired_state       = var.auto_tune_enabled
    rollback_on_disable = "NO_ROLLBACK"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  cluster_config {
    instance_count                = var.instance_count
    instance_type                 = var.instance_type
    multi_az_with_standby_enabled = var.multi_az_with_standby_enabled
    zone_awareness_enabled        = false
    dedicated_master_count        = var.dedicated_master_count
    dedicated_master_enabled      = var.dedicated_master_enabled
    dedicated_master_type         = var.dedicated_master_type
  }

  ebs_options {
    ebs_enabled = true
    iops        = var.ebs_iops
    throughput  = var.ebs_throughput
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  engine_version = var.engine_version

  dynamic "vpc_options" {
    for_each = (var.network_access == "vpc") ? [1] : []

    content {
      security_group_ids = var.security_group_ids
      subnet_ids         = var.subnet_ids
    }
  }

  access_policies = <<POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "*"
          },
          "Action": "es:*",
          "Resource": "${var.opensearch_resource_arn}/*"
        },
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "*"
          },
          "Action": "es:*",
          "Resource": "${var.opensearch_resource_arn}/*",
          "Condition": {
            "IpAddress": {
              "aws:SourceIp": "14.99.102.226"
            }
          }
        },
        {
          "Effect": "Deny",
          "Principal": {
            "AWS": "*"
          },
          "Action": "es:*",
          "Resource": "${var.opensearch_resource_arn}/*",
          "Condition": {
            "IpAddress": {
              "aws:SourceIp": "*"
            }
          }
        }
      ]
    }
  POLICY

  tags = merge(
    {
      "Name"             = var.domain_name
      
    },
    var.extra_tags
  )
}
