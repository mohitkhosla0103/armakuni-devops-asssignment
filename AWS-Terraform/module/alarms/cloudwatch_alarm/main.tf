resource "aws_cloudwatch_metric_alarm" "this" {
  for_each            = var.alarms
  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  actions_enabled     = each.value.actions_enabled

  alarm_description         = lookup(each.value, "alarm_description", null)
  alarm_actions             = lookup(each.value, "alarm_actions", [])
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", [])
  ok_actions                = lookup(each.value, "ok_actions", [])
  dimensions                = each.value.dimensions

      tags = merge(
    {
      Name             = each.value.alarm_name
      TerraformManaged = true
    },
    var.extra_tags
  )
}
