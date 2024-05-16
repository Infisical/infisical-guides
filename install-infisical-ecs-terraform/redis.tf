
resource "aws_cloudwatch_log_group" "redis-slow-log" {
  name = "infisical-core-redis/${var.redis_replication_group_id}/slow-log"
}

resource "aws_cloudwatch_log_group" "redis-engine-log" {
  name = "infisical-core-redis/${var.redis_replication_group_id}/engine-log"
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "infisical-core-redis-subnet"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_parameter_group" "cache_params" {
  name   = "infisical-cache-params"
  family = "redis7"
  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "infisical-redis-cluster"
  description          = "Redis cluster for infisical"

  security_group_ids = [aws_security_group.redis.id]
  subnet_group_name  = aws_elasticache_subnet_group.main.name
   automatic_failover_enabled = true
   num_cache_clusters         = 2
   multi_az_enabled = true

  node_type            = "cache.t2.medium"
  port                 = 6379
  engine               = "redis"
  parameter_group_name = aws_elasticache_parameter_group.cache_params.name

  snapshot_retention_limit = 15
  snapshot_window          = "00:00-05:00"

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis-slow-log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis-engine-log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }
}
