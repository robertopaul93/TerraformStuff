variable "test_cpu" {
  description = "CPU units for the ECS task in the staging environment"
  type        = string
  default     = "256"
}

variable "test_memory" {
  description = "Memory for the ECS task in MiB in the staging environment"
  type        = string
  default     = "512"
}

variable "aurora_master_username" {
  description = "Master username for Aurora"
  type        = string
  default     = "postgres"
}

variable "aurora_master_password" {
  description = "Master password for Aurora"
  type        = string
  sensitive   = true
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "test-table"
}

variable "dynamodb_hash_key" {
  description = "Hash key for DynamoDB table"
  type        = string
  default     = "id"
}