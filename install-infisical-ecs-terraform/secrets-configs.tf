resource "aws_ssm_parameter" "redis_url" {
  name        = "/infisical-core/REDIS_URL"
  description = "Master RDS password"
  type        = "SecureString"
  value       = "redis://${aws_elasticache_replication_group.main.primary_endpoint_address}:${aws_elasticache_replication_group.main.port}"
}