variable "ecr_name" {
  type = string
  description = "(Required) Name of the repository. {project_family}/{environment}/{name}."
}


variable "tags" {
  description = "Tags for the resources"
  type = object({
   
   
  })
}

variable "extra_tags" {
  description = "to add extra tags"
  type        = map(string)
  default     = {}
} 
