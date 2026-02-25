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

run "plan_networking_and_storage" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = module.networking.vpc_cidr == "172.16.0.0/16"
    error_message = "VPC CIDR does not match expected test value"
  }

  assert {
    condition     = module.storage.aurora_backup_retention_period >= 7
    error_message = "Aurora backup retention period should be at least 7 days"
  }
}
