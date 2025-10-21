output "alb_url" {
  value = module.alb_frontend.dns_name
}

output "nodes_sg_id" {
  value = module.alb_frontend.security_group_id
}
