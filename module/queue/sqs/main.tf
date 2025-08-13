resource "aws_sqs_queue" "sqs_standard" {
  count                      = var.fifo_queue ? 0 : 1
  name                       = var.queue_name
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  sqs_managed_sse_enabled    = var.sqs_managed_sse_enabled

  tags = merge(
    {
      "Name"             = var.queue_name
     
    },
    var.extra_tags
  )
}

resource "aws_sqs_queue" "sqs_fifo" {
  count                       = var.fifo_queue ? 1 : 0
  name                        = "${var.queue_name}.fifo"
  delay_seconds               = var.delay_seconds
  max_message_size            = var.max_message_size
  message_retention_seconds   = var.message_retention_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication
  deduplication_scope         = var.deduplication_scope
  fifo_throughput_limit       = var.fifo_throughput_limit
  sqs_managed_sse_enabled     = var.sqs_managed_sse_enabled

  tags = merge(
    {
      "Name"             = var.queue_name
     
    },
    var.extra_tags
  )
}
