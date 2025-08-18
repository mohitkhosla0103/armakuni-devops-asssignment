resource "aws_budgets_budget" "cost_budget" {
  name              = var.budget_name
  budget_type       = "COST"
  limit_amount      = var.budget_amount
  limit_unit        = "USD"
  time_period_start = var.time_period_start
  time_period_end   = var.time_period_end
  time_unit         = var.time_unit

  dynamic "notification" {
    for_each = var.threshold_values
    content {
      comparison_operator        = var.comparison_operator
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = var.notification_type
      subscriber_email_addresses = var.subscriber_email_addresses
    }
  }
}
