output "ecs_cluster_name" {
  description = "ECS cluster name used in alarms"
  value       = var.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ECS service name used in alarms"
  value       = var.ecs_service_name
}

output "alb_arn" {
  description = "ALB ARN used in alarms"
  value       = var.alb_arn
}

output "target_group_arn" {
  description = "Target group ARN used in alarms"
  value       = var.target_group_arn
}
