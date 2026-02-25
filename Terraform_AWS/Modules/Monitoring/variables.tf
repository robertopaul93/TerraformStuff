variable "environment" {
  description = "Environment name (e.g., test, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "aurora_cluster_id" {
  description = "Identifier of the Aurora DB cluster"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "enabled" {
  description = "Whether to create monitoring resources"
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarms go into ALARM state (e.g., SNS topic ARNs)"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarms go into OK state"
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "List of ARNs to notify when alarms go into INSUFFICIENT_DATA state"
  type        = list(string)
  default     = []
}

# Thresholds

variable "ecs_cpu_high_threshold" {
  description = "CPU utilization threshold for ECS high CPU alarm (%)"
  type        = number
  default     = 80
}

variable "ecs_memory_high_threshold" {
  description = "Memory utilization threshold for ECS high memory alarm (%)"
  type        = number
  default     = 80
}

variable "alb_5xx_threshold" {
  description = "Threshold for ALB 5XX errors over 5 minutes"
  type        = number
  default     = 5
}

variable "alb_target_5xx_threshold" {
  description = "Threshold for ALB target 5XX errors over 5 minutes"
  type        = number
  default     = 5
}

variable "alb_latency_threshold" {
  description = "Threshold for ALB target response time (seconds)"
  type        = number
  default     = 0.5
}

variable "aurora_cpu_high_threshold" {
  description = "CPU utilization threshold for Aurora high CPU alarm (%)"
  type        = number
  default     = 80
}

variable "aurora_free_storage_threshold_bytes" {
  description = "Free storage threshold for Aurora (bytes)"
  type        = number
  # Default: 10 GiB
  default     = 10 * 1024 * 1024 * 1024
}

variable "dynamodb_throttled_requests_threshold" {
  description = "Threshold for DynamoDB throttled requests over 5 minutes"
  type        = number
  default     = 1
}
