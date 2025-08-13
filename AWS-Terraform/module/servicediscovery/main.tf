
resource "aws_service_discovery_private_dns_namespace" "private_dns_namespace" {
  count = var.is_internal_service ? 1 : 0

  name        = "${var.ecs_service_cluster_name}.terraform.local"
  description = "Private dns namespace for ${var.ecs_service_cluster_name}"
  vpc         = var.vpc_id
}
