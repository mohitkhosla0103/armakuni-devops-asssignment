variable "db_instance_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
  
}

variable "allocated_storage" {
  type        = number
  default     = 50
  description = "allocates dtorage for rds instance"
}

variable "max_allocated_storage" {
  type        = number
  default     = 500
  description = "allocates dtorage for rds instance"
}

variable "db_name" {
  type        = string
  
  description = "describe db name details"
}

variable "engine" {
  type        = string
  default     = "postgres"
  description = "describe engine name for database"
}

variable "engine_version" {
  type        = number
  default     = 15.4
  description = "describe db engine version"
}

variable "instance_class" {
  type        = string
  default     = "db.m5.large"
  description = "describe db instance class"
}



variable "parameter_group_name" {
  type        = string
  default     = ""
  description = "set db parameter group name for database"
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "set multiaz setup for db instance"
}

variable "performance_insights_enabled" {
  type        = bool
  default     = false
  description = "set performance_insights for db instance"
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "set publicly_accessible for db instance"
}

variable "storage_type" {
  type        = string
  default     = "gp3"
  description = "set storage type for db instance"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "set sg for db instance"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "set final snapshot details"
  default = true
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
}

variable "db_subnet_ids" {
  description = "A list of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "db_subnet_group_tags" {
  description = "A map of tags to assign to the DB subnet group"
  type        = map(string)
}
variable "rds_deletion_protection" {
  description = "Delete protection for rds"
  type        = bool
}

variable "rds_final-snapshot_name" {
  description = "final snapshot name"
  type        = string
}

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

variable "db_subnet_group" {
  type        = string
  default     = ""
  description = "db_subnet_group for db instance"
}

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group"
  type        = string
}

variable "db_parameter_group_family" {
  description = "The family of the DB parameter group"
  type        = string
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "backup retentation period for db instance"
}

# variable "read_replica_count" {
#   type        = string
#   default     = ""
#   description = "read_replica_count value for rds"
# }

variable "master_username" {
  type = string
  description = "username for database"
}

variable "master_password" {
  type = string
  description = "password for database"
}