# Specify the provider and access details

provider "aws" {
  region = "${var.aws_region}"
}

### ECS

resource "aws_ecs_cluster" "main" {
  count = "${var.enabled ? 1: 0}"
  name = "${var.prefix}-cluster"
}

resource "aws_cloudwatch_log_group" "container" {
  count = "${var.enabled ? 1: 0}"
  name  = "/ecs/${var.prefix}-container"
  retention_in_days = "${var.logwatch_retention}"
  tags {
    Application = "${var.prefix}"
  }
}

resource "aws_ecs_task_definition" "app" {
  count                    = "${var.enabled ? 1: 0}"
  family                   = "${var.prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  execution_role_arn       = "${length(var.execution_role) != 0 ? var.execution_role : aws_iam_role.ecs_tasks_execution_role.arn}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory},
    "name": "${var.prefix}-container",
    "networkMode": "awsvpc",
    "environment": ${var.container_env},
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.container.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "protocol": "tcp",
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION
}

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  count              = "${var.enabled && length(var.execution_role) == 0 ? 1: 0}"
  name               = "${var.prefix}-ecs-task-execution-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_execution_role.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  count      = "${var.enabled && length(var.execution_role) == 0 ? 1: 0}"
  role       = "${aws_iam_role.ecs_tasks_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "main" {
  count           = "${var.enabled ? 1: 0}"
  name            = "${var.prefix}-ecs"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"
  health_check_grace_period_seconds = "${var.health_grace_period}"

  network_configuration {
    security_groups  = ["${var.aws_security_group_id}"]
    subnets          = ["${var.aws_subnet_ids}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${var.aws_alb_target_group_id}"
    container_name   = "${var.prefix}-container"
    container_port   = "${var.app_port}"
  }
}
