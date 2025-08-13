output "aurora_cluster_endpoint" {
  description = "The endpoint of the Aurora PostgreSQL cluster"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_cluster_id" {
  description = "The ID of the Aurora PostgreSQL cluster"
  value       = aws_rds_cluster.aurora_cluster.id
}

