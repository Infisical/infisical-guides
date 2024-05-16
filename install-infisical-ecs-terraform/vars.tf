variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
  sensitive   = true
  default     = "us-east-1"
}

variable "redis_replication_group_id" {
  type        = string
  description = "Replication group id for redis cluster"
  default     = "infisical-redis"
}

variable "deployment_stage" {
  type = string
  description = "The stage for deployment (dev, prod, etc)"
}

variable "application_name" {
  type = string
  description = "The name of the application"
  default = "infisical_core_service"
}

variable "cert_domain" {
  type = string
  description = "For which domain to get a certificate for (used for HTTPS)"
}