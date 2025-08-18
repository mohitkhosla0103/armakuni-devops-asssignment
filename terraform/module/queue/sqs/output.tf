output "queue_id" {
  description = "The URL for the created Amazon SQS queue."
  value       = var.fifo_queue ? aws_sqs_queue.sqs_fifo[0].id : aws_sqs_queue.sqs_standard[0].id
}

output "queue_arn" {
  description = "The ARN for the created Amazon SQS queue."
  value       = var.fifo_queue ? aws_sqs_queue.sqs_fifo[0].arn : aws_sqs_queue.sqs_standard[0].arn
}

output "queue_name" {
  description = "The name of the created Amazon SQS queue."
  value       = var.fifo_queue ? aws_sqs_queue.sqs_fifo[0].name : aws_sqs_queue.sqs_standard[0].name
}
