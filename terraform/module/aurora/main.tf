terraform {
required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0.0"
    }
}
}

resource "aws_rds_cluster_parameter_group" "cluster_parameter_group" {
  name        = var.db_cluster_parameter_group_name
  family      = var.db_cluster_parameter_group_family
  description = "RDS cluster parameter group"

#   parameter {
#     name  = "character_set_server"
#     value = "utf8"
#   }

}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = var.db_parameter_group_name
  family = var.db_parameter_group_family

  description = "RDS instance parameter group"

  tags = merge({
    Name          = var.db_parameter_group_name
    },
    var.extra_tags
  )
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = var.rds_subnet_name
  description = "subnet group for RDS"
  subnet_ids  = var.rds_subnet_group_ids
   tags = merge(
    {
     Name=var.rds_subnet_name
     },
    var.extra_tags
  ) 
}

resource "aws_rds_global_cluster" "global_cluster" {
  count = (var.create_global_cluster == true && var.is_primary_cluster ==true ) ? 1 : 0

  global_cluster_identifier = var.global_cluster_identifier
  engine                    = var.engine
  engine_version            = var.engine_version
  storage_encrypted         = true
  deletion_protection       = var.deletion_protection
}





resource "aws_rds_cluster" "aurora_cluster" {

  global_cluster_identifier       = var.create_global_cluster == true ? var.global_cluster_identifier : null
  cluster_identifier              = var.cluster_identifier
  master_username                 = var.is_primary_cluster ? var.master_username : null  # Only set for primary cluster
  master_password                 = var.is_primary_cluster ? var.master_password : null  # Only set for primary cluster
  engine                          = var.engine
  engine_version                  = var.engine_version
  engine_mode                     = var.cluster_engine_mode
  kms_key_id                      = var.kms_key_id                   //use kms key from above module (amano)
  backtrack_window                = var.cluster_backtrack_window
  backup_retention_period         = var.backup_retention_period
  copy_tags_to_snapshot           = var.db_cluster_copy_tags_to_snapshot
  allow_major_version_upgrade     = var.cluster_major_version_upgrade
  #database_name                   = var.database_name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_parameter_group.name // use from above module
  db_subnet_group_name            = aws_db_subnet_group.rds_subnet_group.name //  use from above module
  # delete_automated_backups        = var.delete_automated_backups
  deletion_protection             = var.deletion_protection
  # enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  port                            = var.port
  preferred_backup_window         = var.db_cluster_preferred_backup_window
  preferred_maintenance_window    = var.db_cluster_preferred_maintenance_window
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = "${var.final_snapshot_identifier}-${formatdate("YYYY-MM-DD", timestamp())}"
  storage_encrypted               = var.storage_encrypted
  storage_type                    = var.storage_type                 
  vpc_security_group_ids          = var.aurora_security_group_ids

  serverlessv2_scaling_configuration {
    min_capacity             = var.serverless_min_acu_capacity        
    max_capacity             = var.serverless_max_acu_capacity
  }
  #   lifecycle {
  #   ignore_changes = [global_cluster_identifier]
  # }


  tags = merge(
    {
     Name=var.cluster_identifier
     },
    var.extra_tags
  ) 

}

resource "aws_rds_cluster_instance" "aurora_instance" {
  cluster_identifier                    = aws_rds_cluster.aurora_cluster.id
  engine                                = var.engine
  engine_version                        = var.engine_version

  for_each                              = var.instance_details

  identifier                            = each.key
  instance_class                        = each.value.instance_class
  apply_immediately                     = each.value.apply_immediately
  auto_minor_version_upgrade            = each.value.auto_minor_version_upgrade
  availability_zone                     = each.value.availability_zone
  copy_tags_to_snapshot                 = each.value.db_instance_copy_tags_to_snapshot
  db_parameter_group_name               = aws_db_parameter_group.db_parameter_group.name
  db_subnet_group_name                  = aws_db_subnet_group.rds_subnet_group.name
  monitoring_interval                   = each.value.monitoring_interval
  # monitoring_role_arn                   = each.value.db_instance_monitoring_role_arn
  performance_insights_enabled          = each.value.performance_insights_enabled
  performance_insights_kms_key_id       = each.value.performance_insights_enabled ? each.value.performance_insights_kms_key_id : null
  performance_insights_retention_period = each.value.performance_insights_enabled ? each.value.performance_insights_retention_period : null
  preferred_maintenance_window          = each.value.db_instance_preferred_maintenance_window
  promotion_tier                        = each.value.promotion_tier
  publicly_accessible                   = each.value.publicly_accessible
   tags = merge(
    {
     Name=each.key
     },
    var.extra_tags
  ) 
  
}


//-------------------------------------------------------Read Replica Autoscaling Policy-------------------------------------------------------

resource "aws_appautoscaling_target" "replicas" {
  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.aurora_cluster.id}"
  min_capacity       = var.min_read_replicas
  max_capacity       = var.max_read_replicas
}

resource "aws_appautoscaling_policy" "replicas" {
  name               = var.autoscaling_policy_name
  service_namespace  = aws_appautoscaling_target.replicas.service_namespace
  scalable_dimension = aws_appautoscaling_target.replicas.scalable_dimension
  resource_id        = aws_appautoscaling_target.replicas.resource_id
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.target_metric
    }

    target_value       = var.target_metric_value
    scale_in_cooldown  = var.scale_in_cooldown_period 
    scale_out_cooldown = var.scale_out_cooldown_period
  }

  
}
