module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier                     = "infisical-core-db"
  instance_use_identifier_prefix = true

  create_db_option_group    = false
  create_db_parameter_group = true

  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16" # DB parameter group
  major_engine_version = "1"         # DB option group
  instance_class       = "db.m7g.large"

  allocated_storage = 80

  db_name  = "infisical"
  username = "dbadmin"
  port     = 5432

  multi_az = true

  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [aws_security_group.postgres.id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 15
  manage_master_user_password = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "rds-monitoring-role-infisical-core"
  monitoring_role_use_name_prefix       = true

  # deletion_protection = true
  publicly_accessible = true
  parameters = []
  
}