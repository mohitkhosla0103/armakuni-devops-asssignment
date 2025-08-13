output "private_dns_name" {
  value = "${aws_service_discovery_private_dns_namespace.private_dns_namespace[0].id}"
}
