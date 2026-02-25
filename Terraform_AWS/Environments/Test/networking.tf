module "networking" {
  source = "../../modules/Networking"

  environment          = "test"
  project_name         = "dn-test"
  vpc_cidr             = "172.16.0.0/12"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  private_subnet_cidrs = ["172.16.0.0/18", "172.16.64.0/18"]
  public_subnet_cidrs  = ["172.16.128.0/18", "172.16.192.0/18"]
  single_nat_gateways  = true
}