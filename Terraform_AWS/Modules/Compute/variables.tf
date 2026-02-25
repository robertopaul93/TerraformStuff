variable "environment" { type = string }
variable "project_name" { type = string }
variable "vpc_id" {
  type        = string
  description = "The VPC ID for the ECS service"
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC for ECS security group ingress"
}
variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the ECS service"
}
variable "app_name" {
  type        = string
  default     = "simple-app"
  description = "Name of the application"
}
variable "container_image" {
  type        = string
  default     = "nginx:latest"
  description = "Docker image for the container"
}
variable "container_port" {
  type        = number
  default     = 80
  description = "Port the container listens on"
}
variable "db_endpoint" {
  description = "The endpoint for the Aurora database"
  type        = string
}
variable "cpu" {
  type        = string
  default     = "256"
  description = "CPU units for the task (Fargate)"
}
variable "memory" {
  type        = string
  default     = "512"
  description = "Memory for the task in MiB (Fargate)"
}
variable "desired_count" {
  type        = number
  default     = 1
  description = "Desired number of tasks"
}
variable "target_group_arn" {
  type        = string
  description = "ARN of the target group for the ECS service"
}
