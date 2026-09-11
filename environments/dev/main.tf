module "vpc" {
  source = "../../modules/vpc"

  environment_name      = var.environment_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}

module "alb" {
  source = "../../modules/alb"

  environment_name  = var.environment_name
  app_stack_name    = var.app_stack_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  target_port       = var.container_port
  health_check_path = "/"
}

module "ecs_task" {
  source = "../../modules/ecs_task"

  environment_name = var.environment_name
  app_stack_name   = var.app_stack_name
  service_name     = var.service_name
  image_tag        = var.image_tag
  container_port   = var.container_port
  cpu              = 512
  memory           = 1024
}

module "ecs_service" {
  source = "../../modules/ecs_service"

  environment_name      = var.environment_name
  service_name          = var.service_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  task_definition_arn   = module.ecs_task.task_definition_arn
  container_port        = var.container_port
  desired_count         = var.desired_count
}

module "rds" {
  source = "../../modules/rds"

  environment_name      = var.environment_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.ecs_service.ecs_security_group_id
  db_user               = var.db_user
  db_password           = var.db_password
  db_name               = var.db_name
  engine_version        = var.aurora_engine_version
  serverless_min_acu    = var.serverless_min_acu
  serverless_max_acu    = var.serverless_max_acu
}
