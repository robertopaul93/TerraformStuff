variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "container_port" {
  type        = number
  description = "Port the container listens on"
}

variable "certificate_domain" {
  type        = string
  description = "Domain name for the ACM certificate"
  default     = "example.com"
}