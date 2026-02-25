resource "aws_dynamodb_table" "main" {
  count = var.enable_dynamodb ? 1 : 0

  name         = var.dynamodb_table_name
  billing_mode = var.dynamodb_billing_mode
  hash_key     = var.dynamodb_hash_key

  attribute {
    name = var.dynamodb_hash_key
    type = var.dynamodb_attribute_type
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.data_at_rest.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
