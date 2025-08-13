resource "aws_route" "public_internet_gateway" {
  route_table_id            = var.route_table_id
  destination_cidr_block    = var.destination_cidr_block
  gateway_id                = var.gateway_id
  carrier_gateway_id        = var.carrier_gateway_id
  core_network_arn          = var.core_network_arn
  egress_only_gateway_id    = var.egress_only_gateway_id
  nat_gateway_id            = var.nat_gateway_id
  local_gateway_id          = var.local_gateway_id
  network_interface_id      = var.network_interface_id
  transit_gateway_id        = var.transit_gateway_id
  vpc_endpoint_id           = var.vpc_endpoint_id
  vpc_peering_connection_id = var.vpc_peering_connection_id

  timeouts {
  create = var.create_timeout
  update = var.update_timeout
  delete = var.delete_timeout
  }
}