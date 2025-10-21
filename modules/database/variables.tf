variable "env" {
  description = "The environment for the resources."
  type        = string
}

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the subnet will be created."
  type        = string
}

variable "private_subnet_ids" {
  description = "The ID of the private subnets."
  type        = list(string)
}

variable "backend_sg_id" {
  description = "The ID of the backend security group."
  type        = string
}

variable "db_name" {
  description = "The name of the database."
  type        = string
}

variable "username" {
  description = "The username for the database."
  type        = string
  sensitive   = true
}

variable "password" {
  description = "The password for the database."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
