# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "cb-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "cb-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 4096
  memory                   = 8192
  container_definitions = templatefile("./templates/ecs/cb_app.json.tpl", {
    app_image           = var.app_image
    sidecar_image       = var.sidecar_image
    app_port            = var.app_port
    fargate_cpu         = var.fargate_cpu
    fargate_memory      = var.fargate_memory
    aws_region          = var.aws_region
    machine_identity_id = "<>"
    agent_config = base64encode(file("../agent-config.yaml"))
  })
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

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role, aws_iam_role_policy_attachment.ecs_task_role]
}
