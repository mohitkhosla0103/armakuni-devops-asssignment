variable "widget_files" {
 description = "List of paths to the JSON files for the widgets"
 type       = list(string)
sensitive = true
 }
variable "dashboard_name" {
 description = "Name of Dashboard"
 type       = string
 }
