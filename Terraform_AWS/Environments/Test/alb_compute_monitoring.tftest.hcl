provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  token                       = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
}

variables {
  aurora_master_password = "dummy-password"
  enable_dynamodb        = false
}

run "alb_and_compute_and_monitoring" {
  command = plan

  plan_options {
    refresh = false
  }

  # ECS cluster and service should be named for this environment
  assert {
    condition     = startswith(module.compute_test.ecs_cluster_name, "dn-test-test")
    error_message = "ECS cluster name should start with dn-test-test"
  }

  assert {
    condition     = startswith(module.compute_test.ecs_service_name, "dn-test-test")
    error_message = "ECS service name should start with dn-test-test"
  }

  # Monitoring module should be enabled and wired to the same identifiers
  assert {
    condition     = module.monitoring.ecs_cluster_name == module.compute_test.ecs_cluster_name
    error_message = "Monitoring ECS cluster name should match compute module output"
  }

  assert {
    condition     = module.monitoring.ecs_service_name == module.compute_test.ecs_service_name
    error_message = "Monitoring ECS service name should match compute module output"
  }
}
