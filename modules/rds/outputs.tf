output "db_security_group_id" { value = aws_security_group.db.id }
output "cluster_arn" { value = aws_rds_cluster.aurora.arn }
output "cluster_endpoint" { value = aws_rds_cluster.aurora.endpoint }
output "reader_endpoint" { value = aws_rds_cluster.aurora.reader_endpoint }
output "database_name" { value = aws_rds_cluster.aurora.database_name }
