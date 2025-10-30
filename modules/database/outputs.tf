output "rds_endpoint" {
  value = module.mysql_db.db_instance_endpoint
}

output "rds_instance_id" {
  value = module.mysql_db.db_instance_identifier
}
