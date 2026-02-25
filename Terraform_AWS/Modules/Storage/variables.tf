variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

#VPC Variables
variable "vpc_id" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}

variable "aurora_master_username" {
  description = "Master username for Aurora"
  type        = string
}

variable "aurora_master_password" {
  description = "Master password for Aurora"
  type        = string
  sensitive   = true
}

variable "aurora_database_name" {
  description = "Database name for Aurora"
  type        = string
  default     = "mydb"
}

variable "aurora_instance_class" {
  description = "Instance class for Aurora instances"
  type        = string
  default     = "db.r5.large"
}

variable "aurora_instance_count" {
  description = "Number of Aurora instances"
  type        = number
  default     = 1
}

variable "aurora_allowed_cidr_blocks" {
  description = "Allowed CIDR blocks for Aurora SG ingress"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "VPC security group IDs"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
}

variable "account_id" {
  description = "AWS account ID used in KMS key policy"
  type        = string
  default     = "000000000000"
}

# DynamoDB variables
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "dynamodb_hash_key" {
  description = "Hash key for DynamoDB table"
  type        = string
}

variable "dynamodb_attribute_type" {
  description = "Type of the hash key attribute"
  type        = string
  default     = "S"
}

variable "dynamodb_billing_mode" {
  description = "Billing mode for DynamoDB"
  type        = string
  default     = "PAY_PER_REQUEST"
}

# KMS encryption variables

variable "kms_key_alias" {
  description = "Alias for the KMS key used to encrypt Aurora and DynamoDB"
  type        = string
  default     = "aurora-dynamodb-encryption"
}

variable "kms_key_deletion_window_in_days" {
  description = "Waiting period for KMS key deletion"
  type        = number
  default     = 30
}