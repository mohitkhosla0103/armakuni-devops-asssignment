variable "budget_name" {
 description = "The name of the budget"
 type       = string
}

variable "budget_amount" {
 description = "The budget amount"
 type       = number
 default = 1000
}

variable "time_period_start" {
 description = "The start of the time period covered by the budget"
 type       = string
 default = ""
 
}

variable "time_period_end" {
 description = "The end of the time period covered by the budget"
 type       = string
 default = ""
 
}

variable "time_unit" {
 description = "The length of time until a budget resets"
 type       = string
 
}

variable "subscriber_email_addresses" {
 description = "The email addresses to send notifications to"
 type       = list(string)
 
}

variable "comparison_operator" {
  description = "comparison operator for budget"
  type = string
  default = "GREATER_THAN"
}

variable "threshold_values" {
 description = "The percentage thresholds to trigger notifications at"
 type       = list(number)
 default   = [85, 100]
}

variable "notification_type" {
 description = "The type of budget notification"
 type      = string
}


