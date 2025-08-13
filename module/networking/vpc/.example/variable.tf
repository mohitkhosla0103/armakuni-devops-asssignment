variable "vpc-name" {
  description = "name of the vpc"
  type = string
}

variable "tags" {
  description = "tag of the vpc"
  default = {
    Environment = Production
  }
}

variable "extra_tags" {
  description = "extra tag for the vpc"
  default = {
    Project = "Aws-Project"
  }
}

variable "cidr_block" {
  description = "cide block for vpv"
  type = string
}