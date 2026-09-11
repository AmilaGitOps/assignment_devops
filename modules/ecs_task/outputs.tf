output "task_definition_arn" { value = aws_ecs_task_definition.app.arn }
output "task_definition_family" { value = aws_ecs_task_definition.app.family }
output "ecr_repository_url" { value = local.repository_url }
output "execution_role_arn" { value = aws_iam_role.execution.arn }
output "task_role_arn" { value = aws_iam_role.task.arn }
output "log_group_name" { value = aws_cloudwatch_log_group.ecs.name }
