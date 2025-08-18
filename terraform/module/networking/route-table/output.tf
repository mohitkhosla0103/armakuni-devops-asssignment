output "route_table_association_ids" {
  description = "List of IDs of the route table association"
  value = [for association in aws_route_table_association.rt-association : association.id]
}

output "route_table_ids" {
  description = "List of IDs of intra route tables"
  value = aws_route_table.rt.id
}
