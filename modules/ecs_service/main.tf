resource "aws_security_group" "ecs" {
  name        = "${var.environment_name}-ecs-app-sg"
  description = "Access to Fargate containers in ECS cluster"
  vpc_id      = var.vpc_id
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.environment_name}-ecs-app-sg", Environment = var.environment_name }
}

# Tightened from CFN's 1-65535 range: ALB only needs the actual container port.
resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = var.alb_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = var.container_port
  to_port                      = var.container_port
  description                  = "Ingress from public ALB to application port"
}

# Original CFN allowed all TCP from the ECS SG to itself. Kept for parity.
resource "aws_vpc_security_group_ingress_rule" "from_self" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = 1
  to_port                      = 65535
  description                  = "Ingress from containers using the same security group"
}

resource "aws_ecs_cluster" "this" {
  name = "${var.environment_name}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = { Name = "${var.environment_name} ECS Cluster", Environment = var.environment_name }
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = var.task_definition_arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  lifecycle { ignore_changes = [desired_count] }
}
