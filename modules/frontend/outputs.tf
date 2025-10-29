output "alb_url" {
  value = module.alb_frontend.dns_name
}

output "nodes_sg_id" {
  value = aws_security_group.frontend_nodes_sg.id
}
