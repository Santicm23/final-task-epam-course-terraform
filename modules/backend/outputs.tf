output "nodes_sg_id" {
  value = module.alb_backend.security_group_id
}

output "alb_url" {
  value = module.alb_backend.dns_name
}
