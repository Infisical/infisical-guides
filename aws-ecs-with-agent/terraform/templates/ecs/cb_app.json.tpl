[
  {
    "name": "cb-app",
    "image": "hurlenko/filebrowser:latest",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/cb-app",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "dependsOn": [
      {
        "containerName": "infisical-sidecar",
        "condition": "SUCCESS"
      }
    ],
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ],
    "mountPoints": [
      {
          "sourceVolume": "infisical-efs",
          "containerPath": "/data",
          "readOnly": true
      }
    ]
  },
  {
    "name": "infisical-sidecar",
    "image": "${sidecar_image}",
    "cpu": 1024,
    "memory": 1024,
    "networkMode": "bridge",
    "command": ["agent"],
    "essential": false,
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/agent",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "healthCheck": {
        "command": ["CMD-SHELL", "agent", "--help"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 0
    },
    "environment": [
      {
        "name": "INFISICAL_UNIVERSAL_AUTH_CLIENT_ID",
        "value": "${auth_client_id}"
      },
      {
        "name": "INFISICAL_UNIVERSAL_CLIENT_SECRET",
        "value": "${auth_client_secret}"
      },
      {
        "name": "INFISICAL_AGENT_CONFIG_BASE64",
        "value": "${agent_config}"
      }
    ],
    "mountPoints": [
      {
          "containerPath": "/infisical-agent",
          "sourceVolume": "infisical-efs"
      }
    ]
  }
]
