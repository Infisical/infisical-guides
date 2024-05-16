resource "aws_security_group" "main_alb" {
  vpc_id = module.vpc.vpc_id
  name   = "infisical-alb"

  ingress {
    to_port     = 80
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    to_port     = 443
    from_port   = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "core_server_ecs" {
  vpc_id = module.vpc.vpc_id
  name   = "core_server"

  ingress {
    to_port         = 8080
    from_port       = 8080
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.main_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group_rule" "example" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion_sg.id
  source_security_group_id = aws_security_group.redis.id
}


resource "aws_security_group" "postgres" {
  vpc_id = module.vpc.vpc_id
  name   = "postgres"

  ingress {
    to_port         = 5432
    from_port       = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.core_server_ecs.id, aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "bastion_sg" {
  name = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "redis" {
  vpc_id = module.vpc.vpc_id
  name   = "redis"

  ingress {
    to_port         = 6379
    from_port       = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.core_server_ecs.id, aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

