output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.compute_test.ecs_cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.compute_test.ecs_service_name
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = module.compute_test.ecs_task_definition_arn
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb_test.alb_dns_name
}

output "aurora_cluster_endpoint" {
  description = "Endpoint of the Aurora cluster"
  value       = module.storage.aurora_cluster_endpoint
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.storage.dynamodb_table_name
}