
variable "a1_vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_sn_1_cidr_block" {
  type = string
  default = "10.0.0.0/20"
}

variable "public_sn_2_cidr_block" {
  type = string
  default = "10.0.16.0/20"
}

variable "private_services_sn_1_cidr_block" {
  type = string
  default = "10.0.32.0/20"
}

variable "private_services_sn_2_cidr_block" {
  type = string
  default = "10.0.48.0/20"
}

variable "private_db_1_cidr_block" {
  type = string
  default = "10.0.64.0/20"
}

variable "private_db_2_cidr_block" {
  type = string
  default = "10.0.80.0/20"
}

variable "allow_all_cidr_block" {
  type = string
  default = "0.0.0.0/0"
}

variable "az_us_east_2a" {
  type = string
  default = "us-east-2a"
}

variable "az_us_east_2b" {
  type = string
  default = "us-east-2b"
}

variable "a1_vpc_name" {
  type = string
  default = "a1-vpc"
}

variable "public_sn_1_name" {
  type = string
  default = "public-1"
}

variable "public_sn_2_name" {
  type = string
  default = "public-2"
}

variable "private_services_sn_1_name" {
  type = string
  default = "private-services-1"
}

variable "private_services_sn_2_name" {
  type = string
  default = "private-services-2"
}

variable "private_db_sn_1_name" {
  type = string
  default = "private-db-1"
}

variable "private_db_sn_2_name" {
  type = string
  default = "private-db-2"
}

variable "igw_name" {
  type = string
  default = "main"
}

variable "eip_domain" {
  type = string
  default = "vpc"
}

variable "ng_1_name" {
  type = string
  default = "ng-1"
}

variable "ng_2_name" {
  type = string
  default = "ng-2"
}

variable "nat_1_name" {
  type = string
  default = "ng 1"
}

variable "nat_2_name" {
  type = string
  default = "ng 2"
}

variable "public_rt_name" {
  type = string
  default = "Public Subnets"
}

variable "private_rt_1_name" {
  type = string
  default = "Private Subnet AZ 1"
}

variable "private_rt_2_name" {
  type = string
  default = "Private Subnet AZ 2"
}
