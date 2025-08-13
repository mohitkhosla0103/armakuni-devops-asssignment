variable "bucket" {
  type = string
  description = "name for the bucket."
  
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


variable "bucket_versioning" {
  type = string
  default = "Enabled"
}

# variable "bucket_policy" {
#   type = string
#   description = ""
  
# }
