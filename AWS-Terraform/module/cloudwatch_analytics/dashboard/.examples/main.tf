module "aws_cloudwatch_dashboard" {
    source = "../"
    dashboard_name = var.dashboard_name
    widget_files = var.widget_files
}