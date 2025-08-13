variable "eip-name" {
  description = "name of elastic-ip"
  type = string
}

variable "tags" {
  description = "tag for elastic-ip"
  default = {
    Environment = Production
  }
}

variable "extra_tags" {
  description = "extra tag for elastic-ip"
  default = {
    Project = Aws-project
  }
}