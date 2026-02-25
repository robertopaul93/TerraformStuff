locals {
  alb_suffix_parts          = split("loadbalancer/", var.alb_arn)
  target_group_suffix_parts = split("targetgroup/", var.target_group_arn)

  alb_dimension_value          = length(local.alb_suffix_parts) > 1 ? local.alb_suffix_parts[1] : var.alb_arn
  target_group_dimension_value = length(local.target_group_suffix_parts) > 1 ? local.target_group_suffix_parts[1] : var.target_group_arn
}

############################
# ECS Service Alarms
############################

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  count               = var.enabled ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-high"
  alarm_description   = "ECS service CPU utilization is too high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = var.ecs_cpu_high_threshold
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  period              = 60

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  treat_missing_data        = "notBreaching"
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  count               = var.enabled ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-ecs-memory-high"
  alarm_description   = "ECS service memory utilization is too high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = var.ecs_memory_high_threshold
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  period              = 60

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  treat_missing_data        = "notBreaching"
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

############################
# ALB Alarms
############################

resource "aws_cloudwatch_metric_alarm" "alb_5xx_high" {
  count               = var.enabled ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx-high"
  alarm_description   = "ALB is returning too many 5XX errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.alb_5xx_threshold
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Sum"
  period              = 300

  dimensions = {
    LoadBalancer = local.alb_dimension_value
  }

  treat_missing_data        = "notBreaching"
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_target_5xx_high" {
  count               = var.enabled ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-alb-target-5xx-high"
  alarm_description   = "Targets behind the ALB are returning too many 5XX errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.alb_target_5xx_threshold
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Sum"
  period              = 300

  dimensions = {
    LoadBalancer = local.alb_dimension_value
    TargetGroup  = local.target_group_dimension_value
  }

  treat_missing_data        = "notBreaching"
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_latency_high" {
  count               = var.enabled ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-alb-latency-high"
  alarm_description   = "ALB target response time is too high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.alb_latency_threshold
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Average"
  period              = 300

  dimensions = {
    LoadBalancer = local.alb_dimension_value
    TargetGroup  = local.target_group_dimension_value
  }

  treat_missing_data        = "notBreaching"
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

############################
# Aurora (RDS) Alarms
############################

resource "aws_cloudwatch_metric_alarm" "aurora_cpu_high" {
  count               = var.enabled ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-aurora-cpu-high"
  alarm_description   = "Aurora cluster CPU utilization is too high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = var.aurora_cpu_high_threshold
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  period              = 60

  dimensions = {
    DBClusterIdentifier = var.aurora_cluster_id
  }

  treat_missing_data        = "notBreaching"
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "aurora_storage_low" {
  count               = var.enabled ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-aurora-storage-low"
  alarm_description   = "Aurora cluster free storage space is low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.aurora_free_storage_threshold_bytes
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  period              = 300

  dimensions = {
    DBClusterIdentifier = var.aurora_cluster_id
  }

  treat_missing_data        = "notBreaching"
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

############################
# DynamoDB Alarms
############################

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttled_requests" {
  count               = var.enabled ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-dynamodb-throttled"
  alarm_description   = "DynamoDB table is experiencing throttled requests"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.dynamodb_throttled_requests_threshold
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  statistic           = "Sum"
  period              = 300

  dimensions = {
    TableName = var.dynamodb_table_name
  }

  treat_missing_data        = "notBreaching"
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
