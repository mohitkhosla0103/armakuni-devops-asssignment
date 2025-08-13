variable "ng-name" {
  description = "name of nat-gateway"
}

variable "tags" {
  description = "tags of nat-gateway"
  default = {
    environment = Production
    project     = AWS-Project
  }
}

variable "extra_tags" {
  description = "extra tags for nat-gateway"
  default = {
    Owner = owner-nmae
  }
}