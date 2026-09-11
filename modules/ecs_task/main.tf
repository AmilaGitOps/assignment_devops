data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_ecr_repository" "app" {
  count                = var.create_ecr_repository ? 1 : 0
  name                 = var.app_stack_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
  tags = { Environment = var.environment_name, ManagedBy = "Terraform" }
}

locals {
  repository_url = var.create_ecr_repository ? aws_ecr_repository.app[0].repository_url : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.app_stack_name}"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "${var.environment_name}-ECS-awslogs"
  retention_in_days = var.log_retention_days
  tags              = { Environment = var.environment_name }
}

resource "aws_iam_role" "execution" {
  name = "${var.environment_name}-${var.service_name}-execution-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "execution_managed" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution_secrets" {
  name = "ecs-secrets-access"
  role = aws_iam_role.execution.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = ["secretsmanager:GetSecretValue", "kms:Decrypt"], Resource = "*" }]
  })
}

resource "aws_iam_role" "task" {
  name = "${var.environment_name}-${var.service_name}-task-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

# Kept to represent the original CFN task role permissions. In a real production
# workload, reduce/remove these if the application itself does not call EC2/ELB APIs.
resource "aws_iam_role_policy" "task_legacy_ecs_permissions" {
  name = "ecs-service-legacy-parity"
  role = aws_iam_role.task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:AttachNetworkInterface", "ec2:CreateNetworkInterface", "ec2:CreateNetworkInterfacePermission",
        "ec2:DeleteNetworkInterface", "ec2:DeleteNetworkInterfacePermission", "ec2:Describe*", "ec2:DetachNetworkInterface",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer", "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*", "elasticloadbalancing:RegisterInstancesWithLoadBalancer", "elasticloadbalancing:RegisterTargets"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  volume { name = "my-vol" }

  container_definitions = jsonencode([{
    name         = var.service_name
    image        = "${local.repository_url}:${var.image_tag}"
    cpu          = var.cpu
    memory       = var.memory
    essential    = true
    portMappings = [{ containerPort = var.container_port, hostPort = var.container_port, protocol = "tcp" }]
    mountPoints  = [{ sourceVolume = "my-vol", containerPath = "/var/www/my-vol", readOnly = false }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "${var.app_stack_name}-logs"
      }
    }
  }])

  tags = { Environment = var.environment_name, ManagedBy = "Terraform" }
}
