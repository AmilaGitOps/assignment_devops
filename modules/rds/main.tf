resource "aws_db_subnet_group" "aurora" {
  name        = "${var.environment_name}-aurora-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "RDS private subnet group for Aurora Serverless v2"
  tags        = { Env = "${var.environment_name} RDS Subnet Group" }
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  name        = "${var.environment_name}-aurora-cluster-pg"
  family      = "aurora-mysql8.0"
  description = "Terraform Aurora MySQL cluster parameter group"
  parameter {
    name         = "time_zone"
    value        = "US/Eastern"
    apply_method = "pending-reboot"
  }
  tags = { Env = "${var.environment_name} RDS ClusterParameter Group" }
}

resource "aws_security_group" "db" {
  name        = "${var.environment_name}-db-sg"
  description = "Access to Aurora from ECS"
  vpc_id      = var.vpc_id
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.environment_name}-db-sg", Environment = var.environment_name }
}

resource "aws_vpc_security_group_ingress_rule" "mysql_from_ecs" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = var.ecs_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  description                  = "Aurora MySQL from ECS only"
}

# Modern equivalent of the legacy Aurora Serverless v1 cluster from the CFN.
resource "aws_rds_cluster" "aurora" {
  cluster_identifier              = var.environment_name
  engine                          = "aurora-mysql"
  engine_mode                     = "provisioned"
  engine_version                  = var.engine_version
  database_name                   = var.db_name
  master_username                 = var.db_user
  master_password                 = var.db_password
  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name
  vpc_security_group_ids          = [aws_security_group.db.id]
  enable_http_endpoint            = true
  storage_encrypted               = true
  skip_final_snapshot             = true
  deletion_protection             = false

  serverlessv2_scaling_configuration {
    min_capacity = var.serverless_min_acu
    max_capacity = var.serverless_max_acu
  }

  tags = { Name = "${var.environment_name} Aurora Serverless v2 Cluster", Environment = var.environment_name }
}

resource "aws_rds_cluster_instance" "aurora" {
  count              = 1
  identifier         = "${var.environment_name}-aurora-1"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
}
