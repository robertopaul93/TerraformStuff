module "compute_test" {
  source           = "../../Modules/Compute"
  environment      = "test"
  project_name     = "dn-test"
  vpc_id           = module.networking.vpc_id
  subnet_ids       = module.networking.private_subnet_ids
  target_group_arn = module.alb_test.target_group_arn
  app_name         = "simple-web-app"
  container_image  = "nginx:latest"
  container_port   = 80
  db_endpoint      = module.storage.aurora_cluster_endpoint
  vpc_cidr         = module.networking.vpc_cidr
  cpu              = var.test_cpu
  memory           = var.test_memory
  desired_count    = 2
}

