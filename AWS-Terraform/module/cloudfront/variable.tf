variable "bucket_domain_name" {
  type = string
}

# variable "cloudfront_acm_cert_arn" {
#   type = string
# }

variable "tags" {
  description = "Tags to be applied to resources (inclusive)"
  type = object({
    
  })
}

variable "extra_tags" {
  description = "extra tags to be applied to resources."
  type        = map(string)
  default     = {}
}