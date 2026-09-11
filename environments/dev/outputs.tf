output "service_url" { value = module.alb.service_url }
output "alb_dns_name" { value = module.alb.dns_name }
output "ecr_repository_url" { value = module.ecs_task.ecr_repository_url }
output "ecs_cluster_name" { value = module.ecs_service.ecs_cluster_name }
output "ecs_service_name" { value = module.ecs_service.ecs_service_name }
output "ecs_security_group_id" { value = module.ecs_service.ecs_security_group_id }
output "aurora_endpoint" {
  value     = module.rds.cluster_endpoint
  sensitive = true
}
output "public_subnet_ids" { value = module.vpc.public_subnet_ids }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }
