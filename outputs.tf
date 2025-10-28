output "frontend_alb_url" {
  value = module.frontend.alb_url
}

output "backend_alb_url" {
  value = module.backend.alb_url
}

output "rds_endpoint" {
  value = module.database.rds_endpoint
}

output "bastion_ip" {
  value = module.bastion.bastion_ip
}
