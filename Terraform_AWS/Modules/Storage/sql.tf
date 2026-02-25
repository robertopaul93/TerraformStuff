resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_security_group" "aurora" {
  name   = "${var.project_name}-${var.environment}-aurora-sg"
  vpc_id = var.vpc_id

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

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.project_name}-${var.environment}-aurora"
  engine                  = "aurora-postgresql"
  engine_version          = "13.7"
  master_username         = var.aurora_master_username
  master_password         = var.aurora_master_password
  database_name           = var.aurora_database_name
  vpc_security_group_ids  = var.vpc_security_group_ids
  db_subnet_group_name    = var.db_subnet_group_name
  skip_final_snapshot     = true
  backup_retention_period = 7
  storage_encrypted       = true
  deletion_protection     = true
  kms_key_id              = aws_kms_key.data_at_rest.arn

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_kms_key" "data_at_rest" {
  description             = "KMS key for encrypting Aurora and DynamoDB data"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_kms_alias" "data_at_rest_alias" {
  name          = "alias/${var.project_name}-${var.environment}-${var.kms_key_alias}"
  target_key_id = aws_kms_key.data_at_rest.key_id
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count               = var.aurora_instance_count
  identifier          = "${var.project_name}-${var.environment}-aurora-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = var.aurora_instance_class
  engine              = aws_rds_cluster.aurora.engine
  engine_version      = aws_rds_cluster.aurora.engine_version
  publicly_accessible = false

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}




