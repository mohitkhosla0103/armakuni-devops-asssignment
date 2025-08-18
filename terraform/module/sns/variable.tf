variable "isFifo" {
  description = "Boolean variable to determine if the SNS topic should be FIFO. Default is false."
  type        = bool
  default     = false
}

variable "name" {
  description = "The name of the SNS topic."
  type        = string
}


variable "emails" {
  description = "List of emails for SNS topic subscriptions"
  type        = list(string)
  default     = []
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
