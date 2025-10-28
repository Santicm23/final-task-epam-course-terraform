
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

variable "public_subnet_ids" {
  description = "The ID of the public subnets for the load balancer."
  type        = list(string)
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances."
  type        = string
}

variable "public_key_path" {
  description = "The path to the public key for SSH access."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
