variable "rt-name" {
  description = "name of route table"
}

variable "tags" {
  description = "tag for route table"
  default = {
    Environment = "Production"
  }
}

variable "extra_tags" {
  description = "extra tag for route table"
  default = {
    Project = "aws-project"
  }
}

