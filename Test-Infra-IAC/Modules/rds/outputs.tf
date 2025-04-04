# RDS module outputs

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "rds_host" {
  description = "The hostname of the RDS instance"
  value       = replace(aws_db_instance.main.endpoint, format(":%s", aws_db_instance.main.port), "")
}

output "rds_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.main.id
}