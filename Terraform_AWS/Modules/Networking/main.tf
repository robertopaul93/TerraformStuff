# VPC module main configuration

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # Enable NAT gateways and specify whether to use a single shared NAT gateway
  enable_nat_gateway   = var.enable_nat_gateways
  single_nat_gateway   = var.single_nat_gateways

  # Enable DNS support
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags
  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }

}