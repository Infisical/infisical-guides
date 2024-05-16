terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.deployment_stage
      Terraform   = "true"
      Application = var.application_name
    }
  }
}