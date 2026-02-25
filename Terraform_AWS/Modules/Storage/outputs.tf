# Aurora outputs
output "aurora_cluster_endpoint" {
  description = "Endpoint of the Aurora cluster"
  value       = aws_rds_cluster.aurora.endpoint
}

output "aurora_cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = aws_rds_cluster.aurora.arn
}

output "aurora_cluster_id" {
  description = "ID of the Aurora cluster"
  value       = aws_rds_cluster.aurora.id
}

output "aurora_backup_retention_period" {
  description = "Backup retention period for the Aurora cluster"
  value       = aws_rds_cluster.aurora.backup_retention_period
}

output "aurora_security_group_id" {
  value = aws_security_group.aurora.id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group used by Aurora"
  value       = aws_db_subnet_group.main.name
}

# DynamoDB outputs
output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = length(aws_dynamodb_table.main) > 0 ? aws_dynamodb_table.main[0].arn : null
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = length(aws_dynamodb_table.main) > 0 ? aws_dynamodb_table.main[0].name : null
}