output "opensearch_domain_arn" {
  value = aws_opensearch_domain.opensearch_domain.arn
}

output "opensearch_domain_enspoint" {
  value = aws_opensearch_domain.opensearch_domain.endpoint
}

output "opensearch_domain_name" {
  value = aws_opensearch_domain.opensearch_domain.domain_name
}

output "opensearch_domain_dashboard_endpoint" {
  value = aws_opensearch_domain.opensearch_domain.dashboard_endpoint
}