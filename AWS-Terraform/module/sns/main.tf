
resource "aws_sns_topic" "this" {
  name                        = var.isFifo ? "${var.name}.fifo" : var.name
  fifo_topic                  = var.isFifo
  content_based_deduplication = var.isFifo ? true : null
  tags = merge(
    {
      "Name"             = var.name
  
    },
    var.extra_tags
  )
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  for_each  = toset(var.emails)
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}
