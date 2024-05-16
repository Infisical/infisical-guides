resource "aws_acm_certificate" "cert" {
  domain_name       = var.cert_domain
  validation_method = "DNS"
  key_algorithm = "RSA_2048"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name               = local.name
  vpc_id             = module.vpc.vpc_id
  load_balancer_type = "application"

  subnets = module.vpc.public_subnets

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_groups = [aws_security_group.main_alb.id]

  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "target_ecs"
      }
    }

    ex_https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate.cert.arn

      forward = {
        target_group_key = "target_ecs"
      }
    }
  }

  target_groups = {
    target_ecs = {
      protocol                          = "HTTP"
      port                              = local.infisical_server_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/api/status"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

}
