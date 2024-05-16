locals {
  name                  = "infisical-core-platform"
  infisical_server_port = 8080
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "infisical-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  create_igw         = true

  database_subnets                       = ["10.0.50.0/24", "10.0.51.0/24"]
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true
}
