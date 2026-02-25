
module "storage" {
  source                     = "../../Modules/Storage"
  environment                = "test"
  project_name               = "dn-test"
  account_id                 = "000000000000"
  aurora_master_username     = var.aurora_master_username
  aurora_master_password     = var.aurora_master_password
  aurora_allowed_cidr_blocks = [module.networking.vpc_cidr]
  enable_dynamodb            = var.enable_dynamodb
  vpc_security_group_ids     = [module.storage.aurora_security_group_id]
  private_subnet_ids         = module.networking.private_subnet_ids
  vpc_id                     = module.networking.vpc_id
  db_subnet_group_name       = module.storage.db_subnet_group_name
  dynamodb_table_name        = var.dynamodb_table_name
  dynamodb_hash_key          = var.dynamodb_hash_key
}
