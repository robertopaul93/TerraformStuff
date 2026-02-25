module "monitoring" {
  source = "../../Modules/Monitoring"

  environment  = "test"
  project_name = "dn-test"

  ecs_cluster_name    = module.compute_test.ecs_cluster_name
  ecs_service_name    = module.compute_test.ecs_service_name
  alb_arn             = module.alb_test.alb_arn
  target_group_arn    = module.alb_test.target_group_arn
  aurora_cluster_id   = module.storage.aurora_cluster_id
  dynamodb_table_name = module.storage.dynamodb_table_name

  # Optionally provide SNS topic ARNs or other actions for alarms
  alarm_actions             = []
  ok_actions                = []
  insufficient_data_actions = []
}
