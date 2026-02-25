# Variables for VPC module

variable "environment" {
  description = "Environment name (e.g., test, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.16.0.0/12"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["172.16.0.0/18", "172.16.64.0/18"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["172.16.128.0/18", "172.16.192.0/18"]
}

variable "enable_nat_gateways" {
  description = "Enable NAT gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateways" {
  description = "Use a single shared NAT gateway"
  type        = bool
  default     = false
}