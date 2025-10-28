variable "db_user_name" {
  description = "The username for the database."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database."
  type        = string
  sensitive   = true
}

variable "public_key_path" {
  description = "The file path to the public key used for encryption."
  type        = string
}
