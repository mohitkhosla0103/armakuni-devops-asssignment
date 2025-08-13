variable "ig-name" {
  description = "internet-gateway name"
}

variable "tags" {
  description = "tag for internet gateway"
  default = {
    Environment = "Production"
  }
}

variable "extra_tags" {
  description = "extra tag for internet gateway"
  default = {
    Project = "aws-project"
  }
}