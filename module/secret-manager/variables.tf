variable "secret_name" {
  description = "Name of the secret"
  type        = string
}

variable "secret_type" {
  description = "Type of the secret: either 'username_password' or 'single_string'"
  type        = string
  validation {
    condition     = contains(["username_password", "single_string"], var.secret_type)
    error_message = "secret_type must be 'username_password' or 'single_string'."
  }
}

# Only required if secret_type = "username_password"
variable "username" {
  description = "Username for the secret"
  type        = string
  default     = null
  sensitive = true
}
variable "password" {
  description = "Optional password. if not set, a random one will be generated"
  type        = string
  default     = null
}


# Only required if secret_type = "single_string"
variable "secret_value" {
  description = "The single string value to store in the secret"
  type        = string
  default     = null
  sensitive = true
}