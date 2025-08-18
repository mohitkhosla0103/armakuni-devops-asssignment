variable "tags" {
  description = "Tags for the resources"
  type = object({
   
   
  })
}

variable "extra_tags" {
  description = "to add extra tags"
  type        = map(string)
  default     = {}
} 



//------------------------------------------------------------------- Parameter group & subnet group-----------------------------------------


variable "db_cluster_parameter_group_name" {
  type = string
}

variable "db_cluster_parameter_group_family" {
  type = string
}


variable "db_parameter_group_name" {
  type = string
}

variable "db_parameter_group_family" {
  type = string
}


variable "rds_subnet_name" {
  description = "The name of the DB subnet group."
  type        = string
}

//--------------------------------------------------------------------Aurora Global Cluster---------------------------------------------------------

variable "global_cluster_identifier" {
  type    = string

}

variable "create_global_cluster" {
  type    = bool

}


//--------------------------------------------------------------------Aurora Cluster-----------------------------------------------------------------
variable "is_primary_cluster" {
  type    = bool

}


variable "aurora_security_group_ids" {
  type    = list(string)
  
}

variable "cluster_backtrack_window" {
  type    = string

}

variable "cluster_major_version_upgrade" {
  type    = bool

}


variable "cluster_identifier" {
  description = "The identifier for the Aurora cluster."
}

variable "master_username" {

}

variable "master_password" {

}
variable "engine" {
  description = "The name of the database engine to be used for this cluster."
}

variable "cluster_engine_mode" {
  description = "The mode of the Aurora cluster."
}

variable "engine_version" {
  description = "The engine version to use for the Aurora cluster."
}


variable "kms_key_id" {
  description = "encryption key arn"
}


variable "backup_retention_period" {
  description = "The number of days to retain automated backups."
}

variable "db_cluster_copy_tags_to_snapshot" {
  description = "Copy tags to Aurora snapshots."
}

# variable "database_name" {
#   description = "The name for the default database in the cluster."
# }

# variable "delete_automated_backups" {
#   description = "Indicates whether automated backups should be deleted."
# }

variable "deletion_protection" {
  description = "Indicates whether deletion protection is enabled for the cluster."
}

# variable "enabled_cloudwatch_logs_exports" {
#   description = "List of log types to export to CloudWatch."
#   type        = list(string)
# }


variable "port" {
  description = "The port on which the Aurora cluster accepts connections."
}

variable "db_cluster_preferred_backup_window" {
  description = "The daily time range during which automated backups are created."
}

variable "db_cluster_preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur."
}

variable "skip_final_snapshot" {
  description = "Set to true to skip the final DB snapshot during deletion."
}

variable "final_snapshot_identifier" {
  description = "The name of the final snapshot when deleting the Aurora cluster."
}

variable "storage_encrypted" {
  description = "Indicates whether the Aurora cluster is encrypted."
}

variable "storage_type" {
  description = "The storage type to be associated with the Aurora cluster."
}


variable "rds_subnet_group_ids" {
  description = "A list of VPC subnet IDs."
  type        = list(string)
}


variable "serverless_min_acu_capacity" {
  description = "min configuration of acu"
  type        = string
}

variable "serverless_max_acu_capacity" {
  description = "max configuration of acu"
  type        = string
}


//----------------------------------------------------------------------------aurora instances------------------------------
variable "instance_details" {
  type = any
}


//-------------------------------------------------------Read Replica Autoscaling Policy-------------------------------------------------------
variable "min_read_replicas" {
  type    = string
 
}

variable "max_read_replicas" {
  type    = string

}

variable "autoscaling_policy_name" {
  type    = string

}

variable "target_metric" {
  type    = string

}

variable "target_metric_value" {
  type    = string

}

variable "scale_in_cooldown_period" {
  type    = string
            //time is in seconds
}

variable "scale_out_cooldown_period" {
  type    = string
                 //time is in seconds
}
