output "db_instance_address" {
  description = "The endpoint address of the RDS instance"
  value       = aws_db_instance.db.address
}

output "db_parameter_group" {
  value     = aws_db_parameter_group.db_parameter_group.name
  sensitive = false
}

output "db_subnet_group" {
  value     = aws_db_subnet_group.db_subnet_group.name
  sensitive = false
}

# Define other output values as per your requirements
