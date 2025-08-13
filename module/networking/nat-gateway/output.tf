output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.ng.id
}
