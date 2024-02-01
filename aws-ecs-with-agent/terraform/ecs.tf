# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "cb-cluster"
}

data "template_file" "cb_app" {
  template = file("./templates/ecs/cb_app.json.tpl")

  vars = {
    app_image          = var.app_image
    sidecar_image      = var.sidecar_image
    app_port           = var.app_port
    fargate_cpu        = var.fargate_cpu
    fargate_memory     = var.fargate_memory
    aws_region         = var.aws_region
    auth_client_id     = "faf7da54-75e1-43aa-84be-06453f0b8fc4"
    auth_client_secret = "cb8597f1d5bee779a657e863e5f73c8d4761f3e0c3f6d05c9c2820bc96a0a6f1"
    agent_config       = "aW5maXNpY2FsOgogIGFkZHJlc3M6ICJodHRwczovL2FwcC5pbmZpc2ljYWwuY29tIgogIGV4aXQtYWZ0ZXItYXV0aDogdHJ1ZQphdXRoOgogIHR5cGU6ICJ1bml2ZXJzYWwtYXV0aCIKICBjb25maWc6CiAgICByZW1vdmVfY2xpZW50X3NlY3JldF9vbl9yZWFkOiBmYWxzZQpzaW5rczoKICAtIHR5cGU6ICJmaWxlIgogICAgY29uZmlnOgogICAgICBwYXRoOiAiL2luZmlzaWNhbC1hZ2VudC9hY2Nlc3MtdG9rZW4iCnRlbXBsYXRlczoKICAtIGJhc2U2NC10ZW1wbGF0ZS1jb250ZW50OiBlM3N0SUhkcGRHZ2djMlZqY21WMElDSTJNbVprT1RKaFlUaGlOak01TnpObVpXVXlNMlJsWXpjaUlDSmtaWFlpSUNJdklpQjlmUXA3ZXkwZ2NtRnVaMlVnTGlCOWZRcDdleUF1UzJWNUlIMTlQWHQ3SUM1V1lXeDFaU0I5ZlFwN2V5MGdaVzVrSUgxOUNudDdMU0JsYm1RZ2ZYMD0KICAgIGRlc3RpbmF0aW9uLXBhdGg6IC9pbmZpc2ljYWwtYWdlbnQvLmVudgo="
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "cb-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 4096
  memory                   = 8192
  container_definitions    = data.template_file.cb_app.rendered
  volume {
    name = "infisical-efs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.infisical_efs.id
      root_directory = "/"
    }
  }
}

resource "aws_ecs_service" "main" {
  name            = "cb-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "cb-app"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

