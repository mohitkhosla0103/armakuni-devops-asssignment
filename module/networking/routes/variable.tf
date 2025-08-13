variable "create_timeout" {
  type        = string
  description = "Timeout for resource creation"
  default     = "5m"
}

variable "update_timeout" {
  type        = string
  description = "Timeout for resource updates"
  default     = "2m"
}

variable "delete_timeout" {
  type        = string
  description = "Timeout for resource deletion"
  default     = "5m"
}

variable "route_table_id" {
  type        = string
  description = "The ID of the routing table."
}

variable "destination_cidr_block" {
  type        = string
  description = "The destination CIDR block."
  default     = null
}

variable "destination_ipv6_cidr_block" {
  type        = string
  description = "The destination IPv6 CIDR block."
  default     = null
}

variable "destination_prefix_list_id" {
  type        = string
  description = "The ID of a managed prefix list destination."
  default     = null
}

variable "carrier_gateway_id" {
  type        = string
  description = "Identifier of a carrier gateway. This attribute can only be used when the VPC contains a subnet associated with a Wavelength Zone."
  default     = null
}

variable "core_network_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of a core network."
  default     = null
}

variable "egress_only_gateway_id" {
  type        = string
  description = "Identifier of a VPC Egress Only Internet Gateway."
  default     = null
}

variable "gateway_id" {
  type        = string
  description = "Identifier of a VPC internet gateway or a virtual private gateway. Specify local when updating a previously imported local route."
  default     = null
}

variable "nat_gateway_id" {
  type        = string
  description = "Identifier of a VPC NAT gateway."
  default     = null
}

variable "local_gateway_id" {
  type        = string
  description = "Identifier of an Outpost local gateway."
  default     = null
}

variable "network_interface_id" {
  type        = string
  description = "Identifier of an EC2 network interface."
  default     = null
}

variable "transit_gateway_id" {
  type        = string
  description = "Identifier of an EC2 Transit Gateway."
  default     = null
}

variable "vpc_endpoint_id" {
  type        = string
  description = "Identifier of a VPC Endpoint."
  default     = null
}

variable "vpc_peering_connection_id" {
  type        = string
  description = "Identifier of a VPC peering connection."
  default     = null
}