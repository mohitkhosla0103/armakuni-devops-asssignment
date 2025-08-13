resource "random_password" "generated" {
  count   = var.secret_type == "username_password" && var.password == null ? 1 : 0
  length  = 16
  special = true
}


resource "aws_secretsmanager_secret" "this" {
  name = var.secret_name
}

# Final secret payload (map or string)
locals {
  final_password = var.password != null ? var.password : (
    length(random_password.generated) > 0 ? random_password.generated[0].result : null
  )

  final_secret_value = var.secret_value != null ? var.secret_value : (
    length(random_password.generated) > 0 ? random_password.generated[0].result : null
  )

  secret_payload = var.secret_type == "username_password" ? jsonencode({
    username = var.username
    password = local.final_password
  }) : local.final_secret_value
}


resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = local.secret_payload
}
