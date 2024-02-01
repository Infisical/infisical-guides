# outputs.tf

output "alb_hostname" {
  value = format("%s:%s", aws_alb.main.dns_name, var.app_port)
}

