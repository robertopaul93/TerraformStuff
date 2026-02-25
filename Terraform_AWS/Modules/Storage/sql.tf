# Subnet group for Aurora cluster
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Security group controlling access to Aurora cluster
resource "aws_security_group" "aurora" {
  name        = "${var.project_name}-${var.environment}-aurora-sg"
  description = "Security group for Aurora cluster"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow PostgreSQL access to Aurora"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.aurora_allowed_cidr_blocks
  }

  egress {
    description = "Allow outbound traffic from Aurora"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-aurora-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Aurora PostgreSQL RDS cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.project_name}-${var.environment}-aurora"
  engine                  = "aurora-postgresql"
  engine_version          = "13.7"
  master_username         = var.aurora_master_username
  master_password         = var.aurora_master_password
  database_name           = var.aurora_database_name
  vpc_security_group_ids  = concat(var.vpc_security_group_ids, [aws_security_group.aurora.id])
  db_subnet_group_name    = var.db_subnet_group_name
  skip_final_snapshot     = true
  backup_retention_period = 7
  storage_encrypted       = true
  deletion_protection     = true
  copy_tags_to_snapshot   = true
  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade",
  ]
  iam_database_authentication_enabled = true
  kms_key_id                          = aws_kms_key.data_at_rest.arn

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Caller identity used to build KMS key policy for this account
data "aws_caller_identity" "current" {}

# KMS key for encrypting Aurora and DynamoDB data at rest
resource "aws_kms_key" "data_at_rest" {
  description             = "KMS key for encrypting Aurora and DynamoDB data"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_kms_alias" "data_at_rest_alias" {
  name          = "alias/${var.project_name}-${var.environment}-${var.kms_key_alias}"
  target_key_id = aws_kms_key.data_at_rest.key_id
}

# Aurora cluster instances
resource "aws_rds_cluster_instance" "aurora_instances" {
  count                        = var.aurora_instance_count
  identifier                   = "${var.project_name}-${var.environment}-aurora-instance-${count.index}"
  cluster_identifier           = aws_rds_cluster.aurora.id
  instance_class               = var.aurora_instance_class
  engine                       = aws_rds_cluster.aurora.engine
  engine_version               = aws_rds_cluster.aurora.engine_version
  publicly_accessible          = false
  auto_minor_version_upgrade   = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Backup vault used to store Aurora backups
resource "aws_backup_vault" "aurora" {
  name        = "${var.project_name}-${var.environment}-aurora-backup-vault"
  kms_key_arn = aws_kms_key.data_at_rest.arn

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Backup plan defining Aurora backup schedule and retention
resource "aws_backup_plan" "aurora" {
  name = "${var.project_name}-${var.environment}-aurora-backup-plan"

  rule {
    rule_name         = "${var.project_name}-${var.environment}-aurora-daily-backup"
    target_vault_name = aws_backup_vault.aurora.name
    schedule          = "cron(0 5 * * ? *)" # Daily at 05:00 UTC

    lifecycle {
      delete_after = 35
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM role for RDS enhanced monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project_name}-${var.environment}-aurora-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# IAM role assumed by AWS Backup service
resource "aws_iam_role" "backup" {
  name = "${var.project_name}-${var.environment}-aurora-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# Selects Aurora cluster as a protected resource in the backup plan
resource "aws_backup_selection" "aurora" {
  name         = "${var.project_name}-${var.environment}-aurora-backup-selection"
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.aurora.id

  resources = [
    aws_rds_cluster.aurora.arn,
  ]
}




