module "alb_test" {
  source             = "../../modules/ALB"
  environment        = "test"
  project_name       = "dn-test"
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  container_port     = 80
  certificate_domain = "dn-test.com"
}