variable "queue_name" {
  description = "The name of the SQS queue. Must be 1-80 characters in length and can include alphanumeric characters, hyphens (-), and underscores (_). For FIFO queues, the name must end with .fifo."
  type        = string
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed."
  type        = number
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it."
  type        = number
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message."
  type        = number
}

variable "receive_wait_time_seconds" {
  description = "The maximum time in seconds that a long polling receive call will wait for a message to become available."
  type        = number
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue, in seconds."
  type        = number
}

variable "fifo_queue" {
  description = "Boolean designating a FIFO queue. For standard queues, the value must be false."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues."
  type        = bool
  default     = false
}

variable "deduplication_scope" {
  description = "Specifies whether message deduplication occurs at the message group or queue level."
  type        = string
  default     = "messageGroup"
}

variable "fifo_throughput_limit" {
  description = "Specifies whether the FIFO throughput quota applies to the entire queue or per message group."
  type        = string
  default     = "perMessageGroupId"
}

variable "sqs_managed_sse_enabled" {
  description = "Enables server-side encryption (SSE) using SQS owned encryption keys."
  type        = bool
  default     = true
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