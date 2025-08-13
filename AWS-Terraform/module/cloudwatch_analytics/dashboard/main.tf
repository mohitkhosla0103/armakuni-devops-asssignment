resource "aws_cloudwatch_dashboard" "demo-dashboard" {
 dashboard_name = var.dashboard_name

 dashboard_body = jsonencode({
   widgets = [for f in var.widget_files : jsondecode(file(f))]
 })
}
