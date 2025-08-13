variable "alarms" {
  description = "Map of CloudWatch alarms to create"
  type = map(object({
    alarm_name                = string
    comparison_operator       = string
    evaluation_periods        = number
    metric_name               = string
    namespace                 = string
    period                    = number
    statistic                 = string
    threshold                 = number
    actions_enabled           = bool
    alarm_description         = optional(string, null)
    alarm_actions             = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    dimensions                = map(string)
  }))
}

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