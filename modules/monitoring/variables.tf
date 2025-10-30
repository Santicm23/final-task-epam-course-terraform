variable "project_name" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "backend_alb_arn_suffix" {
  description = "Backend ALB ARN suffix"
  type        = string
}

variable "frontend_alb_arn_suffix" {
  description = "Frontend ALB ARN suffix"
  type        = string
}

# variable "backend_tg_arn_suffix" {
#   description = "Backend Target Group ARN suffix"
#   type        = string
# }

# variable "frontend_tg_arn_suffix" {
#   description = "Frontend Target Group ARN suffix"
#   type        = string
# }

variable "backend_instance_ids" {
  description = "Backend instance IDs"
  type        = list(string)
}

variable "frontend_instance_ids" {
  description = "Frontend instance IDs"
  type        = list(string)
}

variable "rds_instance_id" {
  description = "RDS instance ID"
  type        = string
}
